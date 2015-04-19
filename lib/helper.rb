require 'net/http'

module Helper
  # TODO config

  def connect_storage
    SQLite3::Database.new File.join(__dir__, '../db/sqliquid.db')
  end

  def kick_web_server
    uri = URI('http://localhost:4567/')
    Net::HTTP.post_form(uri, {})
  end

  def get_record(row)
    row.select {|k, v| ['id',
                        'name',
                        'query',
                        'result',
                        'created_at'].include?(k) }
  end
end
