require 'pg'
require 'json'

class Database
  attr_reader :connection

  CONNECTION_OK = PG::CONNECTION_OK

  def self.connect(connection_string)
    Database.new(connection_string)
  end

  def initialize(connection_string)
    @connection = PG::Connection.new(connection_string)
    @ping = PG::Connection.ping(connection_string)
  end

  def connected?
    @ping == PG::PQPING_OK
  end

  def exec(sql)
    @connection.exec(sql)
  end

  def fetch_all(sql)
    # TODO use em-pg-client?
    @connection.send_query(sql)
    @connection.set_single_row_mode
    @connection.get_result.stream_each do |row|
      yield(row)
    end
    @connection.get_result # command end
  end

  def fetch_all_json(sql)
    results = []
    fetch_all(sql) do |row|
      results << row
    end
    results.to_json
  end
end
