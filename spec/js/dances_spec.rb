require 'jseval'
require 'spec_helper'

RSpec.describe 'dances.js' do
  it "sees the JSEval module" do
    expect(JSEval.foo).to eql("foo here")
  end
end
