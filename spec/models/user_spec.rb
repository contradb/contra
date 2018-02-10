require 'rails_helper'

describe User do
  it '#dialect' do
    user = FactoryGirl.build(:user)
    user.preferences.build(FactoryGirl.attributes_for(:move_preference, term: 'gyre', substitution: 'darcy'))
    user.preferences.build(FactoryGirl.attributes_for(:move_preference, term: 'gyre meltdown', substitution: 'meltdown swing'))
    user.preferences.build(FactoryGirl.attributes_for(:dancer_preference, term: 'ladles', substitution: 'ravens'))
    user.preferences.build(FactoryGirl.attributes_for(:dancer_preference, term: 'gentlespoons', substitution: 'larks'))
    dialect = user.dialect
    expect(dialect.length).to eq(2)
    expect(dialect['dancers'].length).to eq(2)
    expect(dialect['dancers']['ladles']).to eq('ravens')
    expect(dialect['dancers']['gentlespoons']).to eq('larks')
    expect(dialect['moves'].length).to eq(2)
    expect(dialect['moves']['gyre']).to eq('darcy')
    expect(dialect['moves']['gyre meltdown']).to eq('meltdown swing')
  end

  describe 'preferences' do
    describe 'relationship' do
      it 'exists' do
        expect(FactoryGirl.build(:user).preferences).to eq([])
      end

      it 'dependant destroy works' do
        user = FactoryGirl.create(:user)
        preference = user.preferences.create(FactoryGirl.attributes_for(:move_preference))
        user.destroy!
        expect(Preference::Preference.find_by(id: preference.id)).to eq(nil)
        expect(Preference::Move.find_by(id: preference.id)).to eq(nil)
      end
    end
  end
end
