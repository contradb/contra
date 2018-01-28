require 'rails_helper'

describe User do
  it '#prefs' do
    user = FactoryGirl.build(:user)
    user.preferences.build(FactoryGirl.attributes_for(:move_preference, term: 'gyre', substitution: 'darcy'))
    user.preferences.build(FactoryGirl.attributes_for(:move_preference, term: 'gyre meltdown', substitution: 'meltdown swing'))
    user.preferences.build(FactoryGirl.attributes_for(:dancer_preference, term: 'ladles', substitution: 'ravens'))
    user.preferences.build(FactoryGirl.attributes_for(:dancer_preference, term: 'gentlespoons', substitution: 'larks'))
    prefs = user.prefs
    expect(prefs.length).to eq(2)
    expect(prefs['dancers'].length).to eq(2)
    expect(prefs['dancers']['ladles']).to eq('ravens')
    expect(prefs['dancers']['gentlespoons']).to eq('larks')
    expect(prefs['moves'].length).to eq(2)
    expect(prefs['moves']['gyre']).to eq('darcy')
    expect(prefs['moves']['gyre meltdown']).to eq('meltdown swing')
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
        expect(Preference.find_by(id: preference.id)).to eq(nil)
      end
    end
  end
end
