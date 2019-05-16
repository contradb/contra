# coding: utf-8

require 'rails_helper'

describe 'Search page', js: true do
  it 'exercise formation filter' do
    visit '/s'
    expect(page).to have_css('.figure-filter-op', count: 3)
    all('.figure-filter-op')[1].select('formation')
    select('proper')
    expect(page).to have_text('state.lisp: [ "and", [ "formation", "proper" ], [ "progression" ] ]')
  end

  describe 'casts' do
    it "cast from 'and' to 'or'" do
      visit '/s'
      expect(page).to have_css('.figure-filter-op', count: 3)
      first('.figure-filter-op').select('or')
      expect(page).to have_text('state.lisp: [ "or", [ "figure", "*" ], [ "progression" ] ]')
    end

    it "cast to 'not'" do
      visit '/s'
      expect(page).to have_css('.figure-filter-op', count: 3)
      first('.figure-filter-op').select('not')
      expect(page).to have_text('state.lisp: [ "not", [ "and", [ "figure", "*" ], [ "progression" ] ] ]')
    end
  end

  describe 'deletion' do
    it "works"
    it "menu item isn't visible for the root node"
    it "menu item isn't visible for a subexpression that's required"
  end

  describe 'datatable' do
    let (:dances) {[:dance, :box_the_gnat_contra, :call_me, :you_cant_get_there_from_here].map {|d| FactoryGirl.create(d)}}

    it 'works (and test formation filter)' do
      dances
      visit '/s'
      dances.each {|dance|
        expect(page).to have_link(dance.title, href: dance_path(dance))
      }
      expect(page).to have_css('.figure-filter-op', count: 3)
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

    it '& filter' do
      dances
      visit '/s'
      expect(page).to have_css('.figure-filter-op', count: 3)
      first('.figure-filter-op').select('&')
      select('chain')
      expect(page).to have_text('state.lisp: [ "&", [ "figure", "chain" ], [ "progression" ] ]')
      expect(page).to_not have_link('The Rendevouz')
      expect(page).to_not have_link('Call Me')
      expect(page).to_not have_link("You Can't Get There From Here")
      expect(page).to have_link('Box the Gnat Contra')
    end

    describe 'figure filter' do
      it 'move works' do
        dances
        visit '/s'
        select 'chain'
        expect(page).to_not have_link('The Rendevouz')
        expect(page).to have_link('Call Me')
        expect(page).to have_link('Box the Gnat Contra')
        expect(page).to_not have_link("You Can't Get There From Here")
      end

      it 'parameters' do
        dances
        visit '/s'
        select 'circle'
        open_ellipsis
        select('4 places')

        expect(page).to_not have_content('Box the Gnat Contra') # no circles
        expect(page).to_not have_content('Call Me') # has circle left 3 places
        expect(page).to have_content('The Rendevouz') # has circle left 3 & 4 places
        expect(page).to_not have_content("You Can't Get There From Here") # circles 3 places

        select('do si do')
        select('neighbors')

        expect(page).to have_content('[ "figure", "do si do", "neighbors", "*", "*", "*" ]')
        expect(page).to_not have_content('The Rendevouz')
        expect(page).to_not have_content('Box the Gnat Contra')
        expect(page).to_not have_content('Call Me')
        expect(page).to have_content("You Can't Get There From Here")
      end
    end
  end

  def open_ellipsis
    find('.toggle-off').click
  end
end
