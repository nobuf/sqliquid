module Helper
  def connect_storage
    # TODO config
    SQLite3::Database.new File.join(__dir__, '../db/sqliquid.db')
  end
end
