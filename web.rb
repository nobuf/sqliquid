require 'sinatra'
require 'sinatra/json'
require 'sqlite3'
require './lib/helper.rb'
set server: 'thin', connection: []
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
    results << row
      .select {|k, v| ['id', 'name', 'query', 'result', 'created_at'].include?(k) }
  end
  json results
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
