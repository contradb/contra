# coding: utf-8

require 'rails_helper'
require 'login_helper'

describe 'Dialect page', js: true do
  it 'displays existings idioms' do
    with_login do |user|
      move_idiom = user.idioms.create(FactoryGirl.attributes_for(:move_idiom, term: 'allemande', substitution: 'almond'))
      dancer_idiom = user.idioms.create(FactoryGirl.attributes_for(:dancer_idiom, term: 'gentlespoons', substitution: 'guys'))

      visit '/dialect'
      expect(page).to have_css('h1', text: "Dialect")
      expect(page).to have_content("#{move_idiom.term} #{move_idiom.substitution}")
      expect(page).to have_content("#{dancer_idiom.term} #{dancer_idiom.substitution}")
    end
  end

  it 'with no idioms, displays help text' do
    with_login do |user|
      visit '/dialect'

      expect(page).to have_content("You may replace gentlespoons with gentlemen, or gyre with gimble, or any term with any substitution.")
    end
  end

  it 'loads help on logging in when accessed without login' do
    visit '/dialect'
    expect(current_path).to eq(new_user_session_path)
  end

  it 'adding an idiom saves to db and updates page' do
    with_login do |user|
      old_idiom_count = Idiom::Idiom.count
      visit '/dialect'
      expect(page).to have_button('Substitute', disabled: true)
      expect(page).to have_css('option', text: 'swing') # js wait
      select 'swing'
      click_button('Substitute')
      expect(page).to have_content("Substitute for “swing”")
      fill_in('idiom_idiom[substitution]', with: 'swong')
      click_on('Save')
      expect(page).to have_content("swing → swong")
      expect(Idiom::Idiom.count).to be(1+old_idiom_count)
      idiom = Idiom::Idiom.last
      expect(idiom).to be_a(Idiom::Move)
      expect(idiom.term).to eq('swing')
      expect(idiom.substitution).to eq('swong')
    end
  end
end
