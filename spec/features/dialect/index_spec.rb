# coding: utf-8

require 'rspec/expectations'

require 'rails_helper'
require 'login_helper'

RSpec::Matchers.define :have_idiom do |idiom|
  match do |page|
    have_idiom_with(idiom.term, idiom.substitution).matches?(page)
  end
end

# there's a bug in this where we don't wait on some submatchers
# so sometimes we've got to js-wait manually
# e.g. after removing a ladles -> ladies idiom:
#      expect(page).to_not have_css("#ladles-substitution") # js wait
#      expect(page).to_not have_idiom_with('ladles', 'ladies')

RSpec::Matchers.define :have_idiom_with do |term, substitution|
  match do |page|
    # TODO: this isn't the right function to call, need to unify with slugifyTerm
    subid = JSLibFigure.slugify_move(term) + '-substitution'
    have_field(subid, with: substitution).matches?(page) && have_content(term).matches?(page)
  end
end

# another approach, with some details here:
# https://groups.google.com/forum/#!searchin/ruby-capybara/matcher%7Csort:date/ruby-capybara/uMaw_gdjCKM/p4CQoowkHAAJ
# Capybara.add_selector(:idiom_with) do
#  css { |term, substitution| puts 'ahoy' ; "input##{JSLibFigure.slugify_move(term)}-substitution" } # also needs to check term and value
# end
# 
# module Capybara
#   class Session
#     def has_idiom_with?(term, substitution)
#       input_with_value = "input##{JSLibFigure.slugify_move(term)}-substitution[value=\"#{substitution}\"]"
#       puts "lhs = " + has_content?(term + ' →').to_s
#       puts "rhs = " + has_selector?(input_with_value).to_s
#       has_selector?(input_with_value) && has_content?(term + ' →')
#     end
#   end
# end



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
        expect(page).to_not have_idiom_with('ladles', 'ladies')
        expect(page).to_not have_idiom_with('first ladle', 'first lady')
        expect(page).to_not have_idiom_with('second ladle', 'second lady')
        expect(page).to_not have_idiom_with('gentlespoons', 'gents')
        expect(page).to_not have_idiom_with('first gentlespoon', 'first gent')
        expect(page).to_not have_idiom_with('second gentlespoon', 'second gent')
        expect(page).to_not have_css('.gents-ladles .btn-primary')

        expect(page).to have_idiom_with('gentlespoons', 'larks')
        expect(page).to have_idiom_with('first gentlespoon', 'first lark')
        expect(page).to have_idiom_with('second gentlespoon', 'second lark')
        expect(page).to have_idiom_with('ladles', 'ravens')
        expect(page).to have_idiom_with('first ladle', 'first raven')
        expect(page).to have_idiom_with('second ladle', 'second raven')
        expect(page).to have_css('.larks-ravens .btn-primary')
        expect(page).to have_css('.glyphicon-ok', count: 6) # load with correct blinkenlight

        click_button('ladies & gents')

        # test html
        expect(page).to have_idiom_with('ladles', 'ladies')
        expect(page).to have_idiom_with('first ladle', 'first lady')
        expect(page).to have_idiom_with('second ladle', 'second lady')
        expect(page).to have_idiom_with('gentlespoons', 'gents')
        expect(page).to have_idiom_with('first gentlespoon', 'first gent')
        expect(page).to have_idiom_with('second gentlespoon', 'second gent')
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
        expect(page).to_not have_css("#ladles-substitution") # js wait to mask bug in have_idiom_with
        expect(page).to_not have_idiom_with('ladles', 'ladies')
        expect(page).to_not have_idiom_with('first ladle', 'first lady')
        expect(page).to_not have_idiom_with('second ladle', 'second lady')
        expect(page).to_not have_idiom_with('gentlespoons', 'gents')
        expect(page).to_not have_idiom_with('first gentlespoon', 'first gent')
        expect(page).to_not have_idiom_with('second gentlespoon', 'second gent')
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

  describe 'idiom list' do

    it 'create' do
      with_login do |user|
        visit '/dialect'
        expect(page).to_not have_css('.glyphicon-ok')
        select 'swing'
        fill_in 'swing-substitution', with: 'swong'
        find('.idiom-substitution').native.send_keys(:return)
        expect(page).to have_css('.glyphicon-ok')
      end
    end

    it 'return works' do
      with_login do |user|
        FactoryGirl.create(:move_idiom, user: user, term: 'see saw', substitution: 'left shoulder do si do')
        visit '/dialect'
        fill_in 'see-saw-substitution', with: 'de ce de'
        find('.idiom-substitution').native.send_keys(:return)
        expect(page).to have_css('.glyphicon-ok') # js wait
        user.reload
        expect(user.idioms.length).to eq(1)
        expect(user.idioms.first.substitution).to eq('de ce de')
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
      expect(page).to have_idiom(move_idiom)
      expect(page).to have_idiom(dancer_idiom)
      expect(page).to_not have_idiom(other_users_idiom)
    end
  end

  it 'loads help on logging in when accessed without login' do
    visit '/dialect'
    expect(current_path).to eq(new_user_session_path)
  end

  it 'Restore Default Dialect button works' do
    with_login do |user|
      dancer_idiom = FactoryGirl.create(:dancer_idiom, user: user, term: 'gentlespoons', substitution: 'brontosauruses')
      move_idiom = FactoryGirl.create(:move_idiom, user: user, term: 'allemande', substitution: 'almond')

      expect(user.idioms).to be_present

      visit '/dialect'

      click_button('Restore Default Dialect')
      # automatically clicks confirm!?

      expect(page).to_not have_idiom(dancer_idiom)
      expect(page).to_not have_idiom(move_idiom)
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
