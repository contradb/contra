require 'jslibfigure'
require 'rails_helper'

RSpec.describe JSLibFigure do
  it "an empty figure has 8 beats" do
    expect(JSLibFigure.beats(JSLibFigure.new)).to eql(8)
  end
  pending 'way more tests here'
end
