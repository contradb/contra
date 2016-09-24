require 'jslibfigure'
require 'rails_helper'

RSpec.describe JSLibFigure do
  it 'an empty figure has 8 beats' do
    expect(JSLibFigure.beats(JSLibFigure.new)).to eql(8)
  end
  describe 'de_alias_move' do
    it 'balance and swing => swing' do
      expect(JSLibFigure.de_alias_move('balance and swing')).to eql('swing')
    end
  end
  pending 'way more tests here'
end
