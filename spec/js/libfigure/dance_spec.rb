require 'jslibfigure'
require 'rails_helper'

RSpec.describe 'dances.js' do
  it "an empty figure has 8 beats" do
    expect(JSLibFigure.eval('figureBeats(newFigure())')).to eql(8)
  end
end
