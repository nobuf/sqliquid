require 'pg/em'
require 'json'

class Database
  attr_reader :connection

  CONNECTION_OK = PG::CONNECTION_OK

  def initialize(connection_string, timeout = 10)
    @connection_string = connection_string
    @timeout = 10
    connect
  end

  def connect
    @connection = PG::EM::Client.new(@connection_string)
    @connection.async_autoreconnect = true
    @connection.query_timeout = @timeout
  end

  def ping?
    PG::Connection.ping(@connection_string) == PG::PQPING_OK
  end

  def exec(sql)
    @connection.exec(sql)
  end

  def close
    @connection.close
  end

  def reconnect
    close
    connect
  end

  def fetch_all(sql, callback = nil)
    EM.run do
      Fiber.new do
        begin
          @connection.query(sql) do |row|
            yield(row)
          end
        rescue => e
          puts e.inspect
          yield({error: e.result.nil? ? e.message : e.result.error_message})
          # TODO better error handling
          # reconnect
        ensure
          EM.stop
        end
      end.resume
      unless callback.nil?
        callback.call
      end
    end
  end
end
