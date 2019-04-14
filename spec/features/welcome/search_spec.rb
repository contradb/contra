# coding: utf-8

require 'rails_helper'

describe 'Search page', js: true do
  it 'changing first child filter to "formation", then changing formation, changes state' do
    visit '/s'
    page.assert_selector('.figure-filter-op', count: 3)
    all('.figure-filter-op')[1].select('formation')
    select('proper')
    expect(page).to have_text('state: [ "and", [ "formation", "proper" ], [ "progression" ] ]')
  end

  describe 'casts' do
    it "cast from 'and' to 'or'" do
      visit '/s'
      page.assert_selector('.figure-filter-op', count: 3)
      first('.figure-filter-op').select('or')
      expect(page).to have_text('state: [ "or", [ "figure", "*" ], [ "progression" ] ]')
    end

    it "cast to 'not'" do
      visit '/s'
      page.assert_selector('.figure-filter-op', count: 3)
      first('.figure-filter-op').select('not')
      expect(page).to have_text('state: [ "not", [ "and", [ "figure", "*" ], [ "progression" ] ] ]')
    end
  end
end
