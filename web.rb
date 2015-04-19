require 'sinatra'
require 'sinatra/json'
require 'sinatra/streaming'
require 'sqlite3'
require 'json'
require './lib/helper.rb'
set server: 'thin', connections: []
set :public_folder, File.join(__dir__, 'public')

include Helper

get '/' do
  erb :index
end

get '/all' do
  results = []
  storage = connect_storage
  storage.results_as_hash = true
  storage.execute('select * from records order by id desc') do |row|
    results << get_record(row)
  end
  json results
end

get '/stream', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << out
    out.callback { settings.connections.delete(out) }
  end
end

post '/' do
  last_record = []
  storage = connect_storage
  storage.results_as_hash = true
  storage.execute('select * from records order by id desc limit 1') do |row|
    last_record << get_record(row)
  end
  settings.connections
    .each { |out| out << "data: #{last_record.to_json}\n\n" }
  204
end

__END__

@@ layout
<html>
  <head>
    <meta charset="utf-8">
    <title>sqliquid</title> 
    <link href="/css/pure-min.css" rel="stylesheet" type="text/css">
    <link href="/css/style.css" rel="stylesheet" type="text/css">
  </head>
  <body>
    <%= yield %>
    <script src="/js/jquery-2.1.3.min.js"></script>
    <script src="/js/jquery.timeago.min.js"></script>
    <script src="/js/records.js"></script>
  </body>
</html>

@@ index
<div id="records" class="content"></div>
