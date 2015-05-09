require 'optparse'
require 'filewatcher'
require 'sqlite3'
require './lib/helper.rb'
require './lib/database.rb'

include Helper

options = {
  dir: '.'
}
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby run.rb [options]'

  opts.on('-s', '--with-webserver', 'Run a web server') do |s|
    options[:with_webserver] = true
  end
  opts.on('-d', '--dir DIR', 'Directory to watch') do |dir|
    options[:dir] = dir
  end
  opts.on('-l', '--limit [LIMIT]', 'Default `LIMIT` for all queries') do |limit|
    options[:limit] = limit.nil? ? 100 : limit.to_i
  end
end.parse!

storage = connect_storage

storage.execute %Q[
  create table if not exists records (
    id integer primary key,
    name text,
    query text,
    result text,
    created_at datetime
  );
]

unless Dir.exists?(options[:dir])
  STDERR.puts "#{options[:dir]} does not exist."
  exit(1)
end

if ENV['SQLIQUID_DATABASE'].nil?
  STDERR.puts 'export SQLIQUID_DATABASE="dbname=abc"'
  exit(1)
end

puts "connecting to the database..."
db = Database.new(ENV['SQLIQUID_DATABASE'])

unless db.ping?
  STDERR.puts "couldn't connect to '#{ENV['SQLIQUID_DATABASE']}'."
  exit(1)
end

sql_files = File.join(options[:dir], '**', '*.sql')
puts "watching... #{sql_files}"

if options[:with_webserver]
  web_server_pid = fork do
    exec 'ruby web.rb'
  end
end

begin
  FileWatcher.new(sql_files).watch do |file_path, event|
    if event == :new || event == :changed
      name = File.basename(file_path, '.sql')
      query = File.read(file_path)

      if options[:limit]
        query = add_limit(query, options[:limit])
      end

      puts query

      created_at = Time.now.to_s

      storage.execute %Q[
        insert into records (name, query, created_at)
          values(?, ?, ?)
        ],
        [name, query, created_at]

      id = storage.last_insert_row_id

      db.fetch_all(query, -> { kick_web_server }) do |result|
        unless result.is_a?(Hash)
          result = Array(result)
        end
        result = result.to_json
        storage.execute %Q[
          update records set result = ?
          where id = ?
        ], [result, id]
        kick_web_server(id)
      end
    end
  end
rescue => e
  puts e.inspect
  puts e.backtrace.join("\n")
  # stop web server
  unless web_server_pid.nil?
    Process.kill 'SIGKILL', web_server_pid
    Process.wait web_server_pid
  end
  puts
  puts "bye!"
end
