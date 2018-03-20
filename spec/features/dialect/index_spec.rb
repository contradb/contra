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
  describe 'role radio button' do
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
        show_advanced_options

        # loads with correct html
        expect(page).to_not have_idiom_with('ladles', 'ladies')
        expect(page).to_not have_idiom_with('first ladle', 'first lady')
        expect(page).to_not have_idiom_with('second ladle', 'second lady')
        expect(page).to_not have_idiom_with('gentlespoons', 'gents')
        expect(page).to_not have_idiom_with('first gentlespoon', 'first gent')
        expect(page).to_not have_idiom_with('second gentlespoon', 'second gent')

        expect(page).to have_idiom_with('gentlespoons', 'larks')
        expect(page).to have_idiom_with('first gentlespoon', 'first lark')
        expect(page).to have_idiom_with('second gentlespoon', 'second lark')
        expect(page).to have_idiom_with('ladles', 'ravens')
        expect(page).to have_idiom_with('first ladle', 'first raven')
        expect(page).to have_idiom_with('second ladle', 'second raven')
        expect(page).to have_css('.glyphicon-ok', count: 6) # load with correct blinkenlight
        expect(find_field("larks-ravens")).to be_checked
        expect(find_field("gents-ladies")).to_not be_checked

        # File.open('/tmp/1.html', 'w') {|f| f.write(.inspect)}

        choose('ladies & gents')

        # test html
        expect(page).to have_idiom_with('ladles', 'ladies')
        expect(page).to have_idiom_with('first ladle', 'first lady')
        expect(page).to have_idiom_with('second ladle', 'second lady')
        expect(page).to have_idiom_with('gentlespoons', 'gents')
        expect(page).to have_idiom_with('first gentlespoon', 'first gent')
        expect(page).to have_idiom_with('second gentlespoon', 'second gent')
        expect(page).to_not have_css('.larks-ravens .btn-primary')
        expect(find_field("larks-ravens")).to_not be_checked
        expect(find_field("gents-ladies")).to be_checked


        # test db
        dancers = user.reload.dialect['dancers']
        expect(dancers['ladles']).to eq('ladies')
        expect(dancers['first ladle']).to eq('first lady')
        expect(dancers['second ladle']).to eq('second lady')
        expect(dancers['gentlespoons']).to eq('gents')
        expect(dancers['first gentlespoon']).to eq('first gent')
        expect(dancers['second gentlespoon']).to eq('second gent')
        expect(page).to have_css('.idiom-form')

        # test delete
        choose('ladles & gentlespoons')
        expect(page).to_not have_css('.idiom-form')
        expect(user.idioms.reload).to be_empty
      end
    end

    it 'no radios are lit when user loads page with unusual dancer idioms' do
      with_login do |user|
        FactoryGirl.create(:dancer_idiom, user: user, term: 'ladles', substitution: 'ladles chicken')
        visit '/dialect'

        expect(find_field("gentlespoons-ladles")).to_not be_checked
        expect(find_field("gents-ladies")).to_not be_checked
        expect(find_field("larks-ravens")).to_not be_checked
        expect(find_field("leads-follows")).to_not be_checked
      end
    end


    it 'ladles and gentlespoons unlights & relights when other stuff shifts underneath its feet' do
      with_login do |user|
        visit '/dialect'
        show_advanced_options

        expect(find_field("gentlespoons-ladles")).to be_checked
        expect(find_field("gents-ladies")).to_not be_checked
        expect(find_field("larks-ravens")).to_not be_checked
        expect(find_field("leads-follows")).to_not be_checked

        select 'ladles'
        fill_in 'ladles-substitution', with: 'T-Rexes'

        expect(page).to have_css('.glyphicon-ok') # js wait
        expect(find_field("gentlespoons-ladles")).to_not be_checked
        expect(find_field("gents-ladies")).to_not be_checked
        expect(find_field("larks-ravens")).to_not be_checked
        expect(find_field("leads-follows")).to_not be_checked

        click_on 'delete-ladles'
        expect(page).to_not have_css('#delete-ladles') # js wait
        expect(find_field("gentlespoons-ladles")).to be_checked
        expect(find_field("gents-ladies")).to_not be_checked
        expect(find_field("larks-ravens")).to_not be_checked
        expect(find_field("leads-follows")).to_not be_checked
      end
    end

    it 'button.selected_role unlights & relights when other stuff shifts underneath its feet' do
      with_login do |user|
        expect(user.idioms).to be_empty
        FactoryGirl.create(:dancer_idiom, user: user, term: 'gentlespoons', substitution: 'larks')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'first gentlespoon', substitution: 'first lark')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'second gentlespoon', substitution: 'second lark')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'ladles', substitution: 'ravens')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'first ladle', substitution: 'first raven')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'second ladle', substitution: 'second raven')

        visit '/dialect'
        expect(page).to have_css('.larks-ravens .btn-primary')
        show_advanced_options

        fill_in 'ladles-substitution', with: 'crows'
        expect(page).to_not have_css('.larks-ravens .btn-primary')

        fill_in 'ladles-substitution', with: 'ravens'
        expect(page).to have_css('.larks-ravens .btn-primary')

        click_on 'delete-ladles'
        expect(page).to_not have_css('.larks-ravens .btn-primary')
      end
    end
  end


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
        show_advanced_options

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
        expect(page).to_not have_css('.larks-ravens .btn-primary')
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
        expect(page).to_not have_css('.dialect-express-role-form .btn-primary')

        # retest db
        expect(user.reload.dialect['dancers']).to be_empty
      end
    end

    it 'button.selected_role unlights & relights when other stuff shifts underneath its feet' do
      with_login do |user|
        expect(user.idioms).to be_empty
        FactoryGirl.create(:dancer_idiom, user: user, term: 'gentlespoons', substitution: 'larks')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'first gentlespoon', substitution: 'first lark')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'second gentlespoon', substitution: 'second lark')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'ladles', substitution: 'ravens')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'first ladle', substitution: 'first raven')
        FactoryGirl.create(:dancer_idiom, user: user, term: 'second ladle', substitution: 'second raven')

        visit '/dialect'
        expect(page).to have_css('.larks-ravens .btn-primary')
        show_advanced_options

        fill_in 'ladles-substitution', with: 'crows'
        expect(page).to_not have_css('.larks-ravens .btn-primary')

        fill_in 'ladles-substitution', with: 'ravens'
        expect(page).to have_css('.larks-ravens .btn-primary')

        click_on 'delete-ladles'
        expect(page).to_not have_css('.larks-ravens .btn-primary')
      end
    end
  end

  describe 'gyre' do

    it "'substitute...' button and dialog work" do
      with_login do |user|
        visit '/dialect'
        show_advanced_options
        expect(page).to have_text('currently using: gyre')
        click_button('substitute...')
        fill_in 'gyre-dialog-substitution', with: 'gazey'
        expect(page).to have_text("Substitute for")
        click_button('Save')
        expect(page).to have_idiom_with('gyre', 'gazey')
        expect(page).to_not have_text("Substitute for")
        expect(page).to have_text('currently using: gazey')
      end
    end
  end

  describe 'idiom list' do

    it 'create move' do
      with_login do |user|
        visit '/dialect'
        show_advanced_options
        expect(page).to_not have_css('.glyphicon-ok')
        select 'swing'
        fill_in 'swing-substitution', with: 'swong' # js wait
        expect(find('.new-move-idiom').value).to eq('')
        expect(page).to have_css('.glyphicon-ok')
      end
    end

    it 'create dancer' do
      with_login do |user|
        visit '/dialect'
        show_advanced_options
        expect(page).to_not have_css('.glyphicon-ok')
        select 'neighbors'
        fill_in 'neighbors-substitution', with: 'buddies' # js wait
        expect(find('.new-dancers-idiom').value).to eq('')
        expect(page).to have_css('.glyphicon-ok')
        expect(user.idioms.length).to eq(1)
        expect(user.idioms.first.term).to eq('neighbors')
        expect(user.idioms.first.substitution).to eq('buddies')
      end
    end

    describe '[x]' do

      it 'works on new idiom' do
        with_login do |user|
          visit '/dialect'
          show_advanced_options
          select 'gate'
          expect(page).to have_idiom_with('gate', 'gate')
          click_on 'delete-gate'
          expect(page).to_not have_idiom_with('gate', 'gate')
          user.reload
          expect(user.idioms.length).to eq(0)
        end
      end

      it 'works on existing idiom' do
        with_login do |user|
          idiom = FactoryGirl.create(:move_idiom, user: user, term: 'gate', substitution: 'flip')
          visit '/dialect'
          show_advanced_options
          expect(page).to have_idiom(idiom)
          click_on 'delete-gate'
          expect(page).to_not have_content('gate') # wanted expect(page).to have_css('.glyphicon-time') but it was flaky
          expect(page).to_not have_idiom(idiom) # also flaky unless guarded
          user.reload
          expect(user.idioms.length).to eq(0)
        end
      end
    end
  end

  describe 'idiom adder select menus' do
    it 'selecting a term that is already present does nothing'
  end


  it 'displays existings idioms' do
    with_login do |user|
      move_idiom = FactoryGirl.create(:move_idiom, user: user, term: 'allemande', substitution: 'almond')
      dancer_idiom = FactoryGirl.create(:dancer_idiom, user: user, term: 'gentlespoons', substitution: 'guys')
      other_users_idiom = FactoryGirl.create(:dancer_idiom, user: FactoryGirl.create(:user), term: 'ladles', substitution: 'ladies')

      visit '/dialect'
      show_advanced_options

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

      expect(page).to_not have_content('gentlespoons')
      expect(page).to_not have_idiom(dancer_idiom)
      expect(page).to_not have_idiom(move_idiom)
      expect(user.reload.idioms).to be_empty
    end
  end

  describe 'Advanced show button' do
    it 'hides and shows idiom editors' do
      with_login do |user|
        idiom = FactoryGirl.create(:move_idiom, user: user, term: 'slice', substitution: 'yearn')
        visit '/dialect'
        expect(page).to_not have_idiom(idiom)
        expect(page).to have_css('.toggle-advanced-content-button', count: 1)
        expect(page).to_not have_css('.toggle-advanced-content-button.btn-primary')
        expect(page).to_not have_css('.new-move-idiom')
        expect(page).to_not have_css('.new-dancers-idiom')
        click_button('show...')
        expect(page).to have_css('.toggle-advanced-content-button.btn-primary')
        expect(page).to have_css('.new-move-idiom')
        expect(page).to have_css('.new-dancers-idiom')
        expect(page).to have_idiom(idiom)
      end
    end
  end

  def idiom_rendering(idiom)
    idiom_attr_rendering(idiom.term, idiom.substitution)
  end

  def idiom_attr_rendering(term, substitution)
    "#{term} → #{substitution}"
  end

  def show_advanced_options
    click_button('show...')
    expect(page).to have_css('.toggle-advanced-content-button.btn-primary') # js wait for completion
  end
end
