require 'rails_helper'

RSpec.describe Idiom, type: :model do

  it '#user' do
    user = FactoryGirl.build(:user)
    idiom = FactoryGirl.build(:move_idiom, user: user) # use move_idiom because idiom is abstract
    expect(idiom.user).to be(user)
  end

  it 'User#destroy also destroys idioms' do
    user = FactoryGirl.create(:user)
    idiom = FactoryGirl.create(:move_idiom, user: user) # use move_idiom because idiom is abstract
    user.destroy!
    expect(Idiom::Idiom.find_by(id: idiom.id)).to eq(nil)
  end
end
