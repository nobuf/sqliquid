require './lib/helper.rb'

describe Helper do
  include Helper

  describe ".add_limit" do
    let(:query) { 'select * from examples' }
    let(:query_with_limit) { 'select * from examples limit 1' }

    it "adds limit 10" do
      expect(add_limit(query, 10))
        .to eq 'select * from examples limit 10'
    end

    it "does not add limit if there's limit" do
      expect(add_limit(query_with_limit, 10))
        .to eq 'select * from examples limit 1'
    end

    context "with complex query" do
      let(:q1) { %Q[
        select 1, (select 1 limit 1)
        from examples
      ] }
      it { expect(add_limit(q1, 10)).not_to eq q1 }
    end
  end
end
