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

  describe 'moves' do
    it 'returns a list of length 20+' do
      expect(JSLibFigure.moves.length).to be > 20
    end

    it "includes 'swing'" do
      expect(JSLibFigure.moves).to include 'swing'
    end

    it "does not include 'gypsy'" do
      expect(JSLibFigure.moves).to_not include 'gypsy'
    end
  end

  describe 'slugify_move / deslugify_move' do
    it "slugify_move works for 'box the gnat'" do
      expect(JSLibFigure.slugify_move('box the gnat')).to eq('box-the-gnat')
    end
    it "deslugify_move works for 'box-the-gnat'" do
      expect(JSLibFigure.deslugify_move('box-the-gnat')).to eq('box the gnat')
    end
    JSLibFigure.moves.each do |move|
      it "#{move.inspect} >> slugify_move >> deslugify_move == #{move.inspect}" do
        expect(JSLibFigure.deslugify_move(JSLibFigure.slugify_move(move))).to eq(move)
      end
    end
  end

  pending 'test the whole libfigure library, ha ha'
end
