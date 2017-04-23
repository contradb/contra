require 'jslibfigure'
require 'rails_helper'

RSpec.describe JSLibFigure do
  it 'an empty figure has 8 beats' do
    expect(JSLibFigure.beats(JSLibFigure.new)).to eql(8)
  end
  describe 'de_aliased_move' do
    it 'see saw => do si do' do
      expect(JSLibFigure.de_aliased_move({'move' => 'see saw'})).to eql('do si do')
    end
    it 'allemande => allemande' do
      expect(JSLibFigure.de_aliased_move({'move' => 'allemande'})).to eql('allemande')
    end
    it 'swat the flea => box the gnat' do
      expect(JSLibFigure.de_aliased_move({'move' => 'swat the flea'})).to eql('box the gnat')
    end
  end
  describe 'teaching_name' do
    it 'swing => swing' do
      expect(JSLibFigure.teaching_name({'move' => 'swing'})).to eql('swing')
    end
    it 'allemande => allemande' do
      expect(JSLibFigure.teaching_name({'move' => 'allemande'})).to eql('allemande')
    end
    it 'swat the flea => swat the flea' do
      expect(JSLibFigure.teaching_name({'move' => 'swat the flea'})).to eql('swat the flea')
    end
    it '[empty figure] => "empty figure"' do
      expect(JSLibFigure.teaching_name({})).to eql('empty figure')
    end
  end

  # calling code moved to a migration, delete this someday
  xit 'hashdiff' do
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

  # calling code moved to a migration, delete this someday
  xit 'hash_remove_key' do
    it 'does nothing on key miss' do
      expect(JSLibFigure.hash_remove_key({}, :a)).to eql({})
    end

    it 'removes the key' do
      expect(JSLibFigure.hash_remove_key({a: 5}, :a)).to eql({})
    end

    it 'does nothing to the original hash' do
      h = {a: 5}
      JSLibFigure.hash_remove_key({a: 5}, :a)
      expect(h).to eql({a: 5})
    end
  end

  pending 'test the whole libfigure library, ha ha'
end
