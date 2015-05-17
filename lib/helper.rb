require 'net/http'
require 'pg_query'

module Helper
  # TODO config

  def connect_storage
    SQLite3::Database.new File.join(__dir__, '../db/sqliquid.db')
  end

  def kick_web_server(id = nil)
    uri = URI('http://localhost:4567/')
    if id.nil?
      Net::HTTP.post_form(uri, {})
    else
      Net::HTTP.post_form(uri, {id: id})
    end
  end

  def get_record(row)
    row.select {|k, v| ['id',
                        'name',
                        'query',
                        'result',
                        'created_at'].include?(k) }
  end

  def add_limit(query, limit)
    # TODO this doesn't work multiple queries in `query`
    begin
      parse_tree = PgQuery.parse(query)
      if parse_tree.parsetree.last['SELECT']['limitCount'].nil?
        return query + " limit #{limit.to_i}"
      end
    rescue PgQuery::ParseError => e
      puts e.class.name + ': ' + e.message
    end
    query
  end
end
