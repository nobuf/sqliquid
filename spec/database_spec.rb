require './lib/database.rb'

describe Database do
  # TODO use config
  let!(:db) { Database.connect('dbname=sqliquid_test port=5432') }
  describe "#connect" do
    it "connects to a database" do
      expect(db.connected?)
        .to be true
    end
  end

  describe "#fetch_all" do
    before(:each) do
      db.exec(%Q[
        create table hello (
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
        expect(row).to eq({'id' => '2'})
      end
    end

    it "returns results for the second query as well" do
      db.fetch_all('select * from hello order by id desc limit 1') {|row| row }
      db.fetch_all('select * from hello order by id desc limit 1') do |row|
        expect(row).to eq({'id' => '2'})
      end
    end
  end
end
