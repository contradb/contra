require 'rails_helper'

describe User do
  it '#prefs' do
    expect(FactoryGirl.build(:user).prefs).to eq(JSLibFigure.stub_prefs)
  end
end
