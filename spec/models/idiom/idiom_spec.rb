require 'rails_helper'

RSpec.describe Idiom, type: :model do
  it '#user' do
    user = FactoryGirl.build(:user)
    idiom = FactoryGirl.build(:move_idiom, user: user) # use move_idiom because idiom is abstract
    expect(idiom.user).to be(user)
  end
end
