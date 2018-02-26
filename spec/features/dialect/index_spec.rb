# coding: utf-8

require 'rails_helper'
require 'login_helper'

describe 'Dialect page', js: true do
  it 'displays existings idioms' do
    with_login do |user|
      move_idiom = FactoryGirl.create(:move_idiom, user: user, term: 'allemande', substitution: 'almond')
      dancer_idiom = FactoryGirl.create(:dancer_idiom, user: user, term: 'gentlespoons', substitution: 'guys')
      other_users_idiom = FactoryGirl.create(:dancer_idiom, user: FactoryGirl.create(:user), term: 'ladles', substitution: 'ladies')

      visit '/dialect'
      expect(page).to have_css('h1', text: "Dialect")
      expect(page).to have_content(idiom_rendering(move_idiom))
      expect(page).to have_content(idiom_rendering(dancer_idiom))
      expect(page).to_not have_content(idiom_rendering(other_users_idiom))
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

  it 'adding a move idiom saves to db and updates page' do
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
      expect(page).to have_content(idiom_attr_rendering('swing', 'swong'))
      expect(Idiom::Idiom.count).to be(1+old_idiom_count)
      idiom = Idiom::Idiom.last
      expect(idiom).to be_a(Idiom::Move)
      expect(idiom.term).to eq('swing')
      expect(idiom.substitution).to eq('swong')
    end
  end

  it 'adding a dancer idiom saves to db and updates page' do
    with_login do |user|
      old_idiom_count = Idiom::Idiom.count
      visit '/dialect'
      expect(page).to have_button('Substitute', disabled: true)
      expect(page).to have_css('option', text: 'ladles') # js wait
      select 'ladles'
      click_button('Substitute')
      expect(page).to have_content("Substitute for “ladles”")
      fill_in('idiom_idiom[substitution]', with: 'ravens')
      click_on('Save')
      expect(page).to have_content(idiom_attr_rendering('ladles', 'ravens'))
      expect(Idiom::Idiom.count).to be(1+old_idiom_count)
      idiom = Idiom::Idiom.last
      expect(idiom).to be_a(Idiom::Dancer)
      expect(idiom.term).to eq('ladles')
      expect(idiom.substitution).to eq('ravens')
    end
  end

  it 'Restore Default Dialect button works' do
    with_login do |user|
      dancer_idiom = FactoryGirl.create(:dancer_idiom, user: user, term: 'gentlespoons', substitution: 'brontosauruses')
      move_idiom = FactoryGirl.create(:move_idiom, user: user, term: 'allemande', substitution: 'almond')

      expect(user.idioms).to be_present

      visit '/dialect'

      click_button('Restore Default Dialect')
      # automatically clicks confirm!?

      # argh! I can't get ujs events to fire, so I can't clear the view. TODO
      expect(page).to_not have_content(idiom_rendering(dancer_idiom))
      expect(page).to_not have_content(idiom_rendering(move_idiom))
      expect(user.reload.idioms).to be_empty
    end
  end

  def idiom_rendering(idiom)
    idiom_attr_rendering(idiom.term, idiom.substitution)
  end

  def idiom_attr_rendering(term, substitution)
    "#{term} → #{substitution}"
  end
end
