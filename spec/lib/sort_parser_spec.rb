require 'ostruct'
require 'spec_helper'
require 'sort_parser'

describe SortParser do
  describe 'parse' do
    it 'works part 1' do
      input = "titleAhookDchoreographer_nameAuser_nameDpublishA"
      expected = [
        "title",
        {"hook" => :desc},
        "choreographers.name",
        User.arel_table[:name].desc,
        "dances.publish"
      ]
      expect(SortParser.parse(input)).to eq(expected)
    end

    it 'works part 2' do
      input = "formationDchoreographer_nameDuser_nameApublishD"
      expected = [
        {"start_type" => :desc},
        Choreographer.arel_table[:name].desc,
        "users.name",
        Dance.arel_table[:publish].desc
      ]
      expect(SortParser.parse(input)).to eq(expected)
    end

    describe "created_at and updated_at" do
      it 'ascending' do
        input = "created_atAupdated_atA"
        expected = [
          "dances.created_at",
          "dances.updated_at",
        ]
        expect(SortParser.parse(input)).to eq(expected)
      end

      it 'descending' do
        input = "created_atDupdated_atD"
        expected = [
          Dance.arel_table[:created_at].desc,
          Dance.arel_table[:updated_at].desc,
        ]
        expect(SortParser.parse(input)).to eq(expected)
      end

    end
    it 'throws an error on bogus input' do
      bogus = 'titlehookA'
      expect {SortParser.parse(bogus)}.to raise_error("SortParser could not read #{bogus.inspect}")
    end

    it 'if the input is empty, returns a default' do
      expect(SortParser.parse("")).to eq([{created_at: :desc}])
    end
  end
end
