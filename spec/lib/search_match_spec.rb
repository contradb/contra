require 'set'
require 'search_match'
require 'rails_helper'

describe SearchMatch do
  describe 'sets' do
    it 'work' do
      expect(Set[SearchMatch.new(4,8)].include?(SearchMatch.new(4,8))).to eq(true)
      expect(Set[SearchMatch.new(4,8)].include?(SearchMatch.new(0,8))).to eq(false)
    end
  end

  describe '|4%8| ==' do
    it do
      expect(SearchMatch.new(4, 8)).to eq(SearchMatch.new(4, 8))
    end

    it do
      expect(SearchMatch.new(4, 8)).to_not eq(SearchMatch.new(4, 5))
    end

    it do
      expect(SearchMatch.new(4, 8, count: 2)).to_not eq(SearchMatch.new(4, 8))
    end
  end

  describe '#abut' do
    it 'returns a new search_match on success' do
      expect(SearchMatch.new(4,8).abut(SearchMatch.new(5,8))).to eq(SearchMatch.new(4,8, count: 2))
    end

    it 'returns nil when they do not touch' do
      expect(SearchMatch.new(4,8).abut(SearchMatch.new(6,8))).to eq(nil)
    end

    it 'returns nil when they overlap' do
      expect(SearchMatch.new(4,8, count: 5).abut(SearchMatch.new(5,8, count: 6))).to eq(nil)
    end

    it 'wraps' do
      result = SearchMatch.new(4,5).abut(SearchMatch.new(0,5))
      expect(result).to eq(SearchMatch.new(4, 5, count: 2))
      expect(result.first).to eq(4)
      expect(result.last).to eq(0)
      expect(result.count).to eq(2)
      expect(result.nfigures).to eq(5)
    end

    it 'does not just always wrap' do
      expect(SearchMatch.new(4,8).abut(SearchMatch.new(0,8))).to eq(nil)
    end

    it 'self-wraps' do
      result = SearchMatch.new(0, 4, count: 4).abut(SearchMatch.new(0, 4, count: 4))
      expect(result.first).to eq(0)
      expect(result.last).to eq(3)
      expect(result.count).to eq(8)
    end
  end

  describe '#include?' do
    it 'works' do
      search_match = SearchMatch.new(4,8)
      search_match.nfigures.times do |i|
        expect(search_match.include?(i)).to eq(i==4)
      end
    end

    it 'wraps' do
      search_match = SearchMatch.new(6, 8, count: 4)
      search_match.nfigures.times do |i|
        expect(search_match.include?(i)).to eq(i.in?([6,7,0,1]))
      end
    end
  end

  it '#each' do
    search_match = SearchMatch.new(6, 8, count: 4)
    ncalls = 0
    expected_indexes = [6,7,0,1]
    search_match.each do |i|
      expect(i).to eq(expected_indexes[ncalls])
      ncalls += 1
    end
    expect(ncalls).to eq(4)
  end

  it '#map' do
    expect(SearchMatch.new(6, 8, count: 4).map.to_a).to eq([6,7,0,1])
  end

  describe '.to_index_array' do
    it '(set)' do
      nfigures = 8
      sms = Set[SearchMatch.new(2, nfigures),
                SearchMatch.new(4, nfigures),
                SearchMatch.new(6, nfigures, count: 4)]
      expect(SearchMatch.to_index_array(sms)).to eq([0,1,2,4,6,7])
    end

    it '(nil)' do
      expect(SearchMatch.to_index_array(nil)).to eq([])
    end
  end
end
