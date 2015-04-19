require 'filewatcher'
require 'sqlite3'
require './lib/helper.rb'
require './lib/database.rb'

include Helper

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

dir = ARGV.first
if dir.nil?
  STDERR.puts 'usage: ruby run.rb <directory to watch>'
  exit(1)
end

unless Dir.exists?(dir)
  STDERR.puts "#{dir} does not exist."
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

sql_files = File.join(dir, '**', '*.sql')
puts "watching... #{sql_files}"

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
  puts
  puts "bye!"
end
