require 'rails_helper'

RSpec.describe Preference, type: :model do
  it '#user' do
    user = FactoryGirl.build(:user)
    preference = FactoryGirl.build(:move_preference, user: user) # use move_preference because preference is abstract
    expect(preference.user).to be(user)
  end
end
