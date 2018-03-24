require 'rails_helper'

describe Idiom::Dancer do
  it 'has a working factory' do
    dancer_idiom = FactoryGirl.build(:dancer_idiom, user: FactoryGirl.build(:user))
    expect(dancer_idiom).to be_valid
    expect(dancer_idiom.type).to eq('Idiom::Dancer')
  end
end
