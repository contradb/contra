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

  describe 'datatable' do
    let (:dances) {[:dance, :box_the_gnat_contra, :call_me, :you_cant_get_there_from_here].map {|d| FactoryGirl.create(d)}}

    it 'works (and test formation filter)' do
      dances
      visit '/s'
      dances.each {|dance|
        expect(page).to have_link(dance.title, href: dance_path(dance))
      }
      page.assert_selector('.figure-filter-op', count: 3)
      all('.figure-filter-op')[1].select('formation')
      select('Becket *')
      dances.each do |dance|
        to_or_to_not = dance.start_type.include?("Becket") ? :to : :to_not
        expect(page).send(to_or_to_not, have_link(dance.title, href: dance_path(dance)))
      end
    end

    it 'count filter' do
      dances
      visit '/s'
      first('.figure-filter-op').select('figure')
      first('.figure-filter-op').select('number of')
      select('≠')
      select('7')
      matches = 0
      dances.each do |dance|
        not_seven = dance.figures.length != 7
        matches += 1 if not_seven
        to_or_to_not = not_seven ? :to : :to_not
        expect(page).send(to_or_to_not, have_link(dance.title, href: dance_path(dance)))
      end
      expect(matches).to eq(1)
    end
  end
end
