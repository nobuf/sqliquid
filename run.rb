require 'optparse'
require 'filewatcher'
require 'sqlite3'
require './lib/helper.rb'
require './lib/database.rb'

include Helper

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby run.rb [options]'

  opts.on('-s', '--with-webserver', 'Run a web server') do |s|
    options[:with_webserver] = true
  end
  opts.on('-d', '--dir DIR', 'Directory to watch') do |dir|
    options[:dir] = dir
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
db = Database.connect(ENV['SQLIQUID_DATABASE'])

unless db.connected?
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
      puts query
      begin
        # TODO reconnect if it's dropped
        result = db.fetch_all_json(query)
      rescue PG::Error => e
        puts e.inspect
        result = {error: e.result.error_message}.to_json
        db.clear
      end

      created_at = Time.now.to_s

      storage.execute %Q[
        insert into records (name, query, result, created_at)
          values(?, ?, ?, ?)
        ],
        [name, query, result, created_at]

      kick_web_server
    end
  end
rescue SystemExit, Interrupt
  # stop web server
  unless web_server_pid.nil?
    Process.kill 'SIGKILL', web_server_pid
    Process.wait web_server_pid
  end
  puts
  puts "bye!"
end
