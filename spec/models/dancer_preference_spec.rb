require 'rails_helper'

describe DancerPreference do
  it 'has a working factory' do
    dancer_preference = FactoryGirl.build(:dancer_preference, user: FactoryGirl.build(:user))
    expect(dancer_preference).to be_valid
    expect(dancer_preference.type).to eq('DancerPreference')
  end
end
