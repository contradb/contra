require 'rails_helper'

describe Idiom::Move do
  it 'has a working factory' do
    move_idiom = FactoryGirl.build(:move_idiom, user: FactoryGirl.build(:user))
    expect(move_idiom).to be_valid
    expect(move_idiom.type).to eq('Idiom::Move')
  end
end
