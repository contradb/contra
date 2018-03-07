# coding: utf-8

require 'rails_helper'
require 'login_helper'

describe 'Dialect page', js: true do
  describe 'role button' do
    it 'works' do
      with_login do |user|
        expect(user.idioms).to be_empty
        FactoryGirl.create(:dancer_idiom, user: user, term: 'gentlespoons', substitution: 'larks')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'first gentlespoon', substitution: 'first lark')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'second gentlespoon', substitution: 'second lark')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'ladles', substitution: 'ravens')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'first ladle', substitution: 'first raven')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'second ladle', substitution: 'second raven')

        visit '/dialect'

        # loads with correct html
        expect(page).to_not have_content(idiom_attr_rendering('ladles', 'ladies'))
        expect(page).to_not have_content(idiom_attr_rendering('first ladle', 'first lady'))
        expect(page).to_not have_content(idiom_attr_rendering('second ladle', 'second lady'))
        expect(page).to_not have_content(idiom_attr_rendering('gentlespoons', 'gents'))
        expect(page).to_not have_content(idiom_attr_rendering('first gentlespoon', 'first gent'))
        expect(page).to_not have_content(idiom_attr_rendering('second gentlespoon', 'second gent'))
        expect(page).to_not have_css('.gents-ladles .btn-primary')

        expect(page).to have_content(idiom_attr_rendering('gentlespoons', 'larks'))
        expect(page).to have_content(idiom_attr_rendering('first gentlespoon', 'first lark'))
        expect(page).to have_content(idiom_attr_rendering('second gentlespoon', 'second lark'))
        expect(page).to have_content(idiom_attr_rendering('ladles', 'ravens'))
        expect(page).to have_content(idiom_attr_rendering('first ladle', 'first raven'))
        expect(page).to have_content(idiom_attr_rendering('second ladle', 'second raven'))
        expect(page).to have_css('.larks-ravens .btn-primary')

        click_button('ladies & gents')

        # test html
        expect(page).to have_content(idiom_attr_rendering('ladles', 'ladies'))
        expect(page).to have_content(idiom_attr_rendering('first ladle', 'first lady'))
        expect(page).to have_content(idiom_attr_rendering('second ladle', 'second lady'))
        expect(page).to have_content(idiom_attr_rendering('gentlespoons', 'gents'))
        expect(page).to have_content(idiom_attr_rendering('first gentlespoon', 'first gent'))
        expect(page).to have_content(idiom_attr_rendering('second gentlespoon', 'second gent'))
        expect(page).to have_css('.gents-ladies .btn-primary')

        # test db
        dancers = user.reload.dialect['dancers']
        expect(dancers['ladles']).to eq('ladies')
        expect(dancers['first ladle']).to eq('first lady')
        expect(dancers['second ladle']).to eq('second lady')
        expect(dancers['gentlespoons']).to eq('gents')
        expect(dancers['first gentlespoon']).to eq('first gent')
        expect(dancers['second gentlespoon']).to eq('second gent')

        # toggle it off again
        click_button('ladies & gents')

        # retest html
        expect(page).to_not have_content(idiom_attr_rendering('ladles', 'ladies'))
        expect(page).to_not have_content(idiom_attr_rendering('first ladle', 'first lady'))
        expect(page).to_not have_content(idiom_attr_rendering('second ladle', 'second lady'))
        expect(page).to_not have_content(idiom_attr_rendering('gentlespoons', 'gents'))
        expect(page).to_not have_content(idiom_attr_rendering('first gentlespoon', 'first gent'))
        expect(page).to_not have_content(idiom_attr_rendering('second gentlespoon', 'second gent'))
        expect(page).to_not have_css('.btn-primary')

        # retest db
        expect(user.reload.dialect['dancers']).to be_empty
      end
    end

    it 'button.selected_role unlights & relights when other stuff shifts underneath its feet'
    # * other button pressed
    # * idiom changed
    # * idiom deleted
  end

  describe 'gyre' do
    it 'text field'
    it '[x]'
    it 'shoulder'
  end

  describe 'main list' do
    it 'text field' do
      with_login do |user|
        visit '/dialect'
        expect(page).to_not have_css('.glyphicon-ok')
        select 'swing'
        fill_in 'swing →', with: 'swong'
        expect(page).to have_css('.glyphicon-ok')
      end
    end
    it '[x]'
  end

  describe 'idiom adder selects' do
    it 'dancer'
    it 'move'
    it 'clear all dancers'
    it 'clear all moves'
    it 'selecting a term that is already present does nothing'
  end


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
