# coding: utf-8
require 'rails_helper'
require 'login_helper'

describe 'Editing preferences' do
  it 'edits existing preferences' do
    with_login do |user|
      user.preferences.create(FactoryGirl.attributes_for(:move_preference, term: 'allemande', substitution: 'almond'))
      user.preferences.create(FactoryGirl.attributes_for(:dancer_preference, term: 'gentlespoons', substitution: 'guys'))
      visit edit_preferences_path
      expect(page).to have_field('preferences_form_preferences_attributes_0_term', with: 'allemande')
      expect(page).to have_field('preferences_form_preferences_attributes_0_substitution', with: 'almond')
      expect(page).to have_field('preferences_form_preferences_attributes_1_term', with: 'gentlespoons')
      expect(page).to have_field('preferences_form_preferences_attributes_1_substitution', with: 'guys')
      fill_in('preferences_form_preferences_attributes_0_substitution', with: 'albatross')
      fill_in('preferences_form_preferences_attributes_1_substitution', with: 'fellas')

      click_button('Save Preferences')
      user.reload

      expect(user.preferences.moves.length).to eq(1)
      move = user.preferences.moves.first
      expect(move.term).to eq('allemande')
      expect(move.substitution).to eq('albatross')
      expect(move.user_id).to eq(user.id)

      expect(user.preferences.dancers.length).to eq(1)
      dancers = user.preferences.dancers.first
      expect(dancers.term).to eq('gentlespoons')
      expect(dancers.substitution).to eq('fellas')
      expect(dancers.user_id).to eq(user.id)
    end
  end
end
