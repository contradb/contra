require 'ostruct'
require 'spec_helper'
require 'sort_parser'

describe SortParser do
  describe 'parse' do
    it 'works' do
      expected = [
        OpenStruct.new(column: 'title', ascending: true),
        OpenStruct.new(column: 'hook', ascending: false),
        OpenStruct.new(column: 'choreographer_name', ascending: true),
      ]
      expect(SortParser.parse("titleAhookDchoreographer_nameA")).to eq(expected)
    end

    it 'throws an error on bogus input' do
      bogus = 'ti[tleA'
      expect {SortParser.parse(bogus)}.to raise_error("SortParser could not read #{bogus.inspect}")
    end

    it 'if the input is empty, returns a default' do
      expect(SortParser.parse("")).to eq([OpenStruct.new(column: 'created_at', ascending: false)])
    end
  end
end
