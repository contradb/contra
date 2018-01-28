require 'rails_helper'

describe Preference::Dancer do
  it 'has a working factory' do
    dancer_preference = FactoryGirl.build(:dancer_preference, user: FactoryGirl.build(:user))
    expect(dancer_preference).to be_valid
    expect(dancer_preference.type).to eq('Preference::Dancer')
  end
end
