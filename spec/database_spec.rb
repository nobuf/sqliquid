require './lib/database.rb'

describe Database do
  # TODO use config
  let!(:db) { Database.new('dbname=sqliquid_test port=5432') }
  describe "#ping" do
    it "connects to a database" do
      expect(db.ping?)
        .to be true
    end
  end

  describe "#fetch_all" do
    before(:each) do
      db.exec(%Q[
        create table if not exists hello (
          id integer
        );
        insert into hello values(1), (2);
      ])
    end

    after(:each) do
      db.exec('drop table hello;')
    end

    it "returns two values" do
      db.fetch_all('select * from hello order by id desc limit 1') do |row|
        expect(row.class).to be PG::Result
      end
    end

    it "returns results for the second query as well" do
      db.fetch_all('select * from hello order by id desc limit 1') {|row| row }
      db.fetch_all('select * from hello order by id desc limit 1') do |row|
        expect(row.class).to be PG::Result
      end
    end

    # TODO not sure how to test connection timed out or disconnected
    # context "disconnected" do
    #   before(:each) do
    #     db.close
    #   end
    #   it "reconnects and returns results" do
    #     db.fetch_all('select * from hello order by id desc limit 1') do |row|
    #        expect(row.class).to be PG::Result
    #     end
    #   end
    # end
  end
end
