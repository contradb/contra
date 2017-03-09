require 'jslibfigure'
require 'rails_helper'

RSpec.describe JSLibFigure do
  it 'an empty figure has 8 beats' do
    expect(JSLibFigure.beats(JSLibFigure.new)).to eql(8)
  end
  describe 'de_aliased_move' do
    it 'balance and swing => swing' do
      expect(JSLibFigure.de_aliased_move({'move' => 'balance and swing'})).to eql('swing')
    end
    it 'allemande => allemande' do
      expect(JSLibFigure.de_aliased_move({'move' => 'allemande'})).to eql('allemande')
    end
    it 'swat the flea => box the gnat' do
      expect(JSLibFigure.de_aliased_move({'move' => 'swat the flea'})).to eql('box the gnat')
    end
  end
  describe 'teaching_name' do
    it 'balance and swing => swing' do
      expect(JSLibFigure.teaching_name({'move' => 'balance and swing'})).to eql('swing')
    end
    it 'allemande => allemande' do
      expect(JSLibFigure.teaching_name({'move' => 'allemande'})).to eql('allemande')
    end
    it 'swat the flea => swat the flea' do
      expect(JSLibFigure.teaching_name({'move' => 'swat the flea'})).to eql('swat the flea')
    end
  end

  describe 'hashdiff' do
    it '[{},{}] => [{},{}]' do
      expect(JSLibFigure.hashdiff [{},{}]).to eql([{},{}])
    end

    it '[{a: 5},{}] => [{a: 5},{}]' do
      expect(JSLibFigure.hashdiff [{a: 5},{}]).to eql([{a: 5},{}])
    end

    it '[{},{a: 7}] => [{},{a: 7}]' do
      expect(JSLibFigure.hashdiff [{},{a: 7}]).to eql([{},{a: 7}])
    end

    it '[{a: 5},{b: 7}] => [{a: 5},{b: 7}]' do
      expect(JSLibFigure.hashdiff [{a: 5},{b: 7}]).to eql([{a: 5},{b: 7}])
    end

    it '[{a: 5},{a: 7}] => [{a: 5},{a: 7}]' do
      expect(JSLibFigure.hashdiff [{a: 5},{a: 7}]).to eql([{a: 5},{a: 7}])
    end

    it '[{a: 5},{a: 5}] => [{},{}]' do
      expect(JSLibFigure.hashdiff [{a: 5},{a: 5}]).to eql([{},{}])
    end
  end

  pending 'test the whole libfigure library, ha ha'
end
