require 'rails_helper'

describe MovePreference do
  it 'has a working factory' do
    move_preference = FactoryGirl.build(:move_preference, user: FactoryGirl.build(:user))
    expect(move_preference).to be_valid
    expect(move_preference.type).to eq('MovePreference')
  end
end
