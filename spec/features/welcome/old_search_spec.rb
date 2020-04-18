# coding: utf-8

require 'rails_helper'

describe 'Search page', js: true do
  def visit_page_with_testing_query
    visit '/s'
    select 'and'
    find_all('.search-ex-op', count: 3).last.select('progression')
    # ['and', ['figure', '*'], ['progression']]
  end

  describe 'datatable' do
    let (:dances) {
      ds = [:dance, :box_the_gnat_contra, :call_me, :you_cant_get_there_from_here].map {|d| FactoryGirl.create(d)}
      tag_all_dances
      ds
    }

    xit 'works (and test formation filter)' do
      dances
      visit_page_with_testing_query
      dances.each {|dance|
        expect(page).to have_link(dance.title, href: dance_path(dance))
      }
      all('.search-ex-op', count: 3)[1].select('formation')
      select('Becket *')
      dances.each do |dance|
        to_or_to_not = dance.start_type.include?("Becket") ? :to : :to_not
        expect(page).send(to_or_to_not, have_link(dance.title, href: dance_path(dance)))
      end
    end

    xit 'count filter' do
      dances
      visit_page_with_testing_query
      first('.search-ex-op').select('figure')
      first('.search-ex-op').select('number of')
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

    xit 'tag and compare filters' do
      verified = FactoryGirl.create(:tag, :verified)
      broken = FactoryGirl.create(:tag, :please_review)
      call_me = dances.find {|dance| dance.title == "Call Me"}
      the_rendevouz = dances.find {|dance| dance.title == "The Rendevouz"}
      1.times { FactoryGirl.create(:dut, tag: verified, dance: call_me) }
      2.times { FactoryGirl.create(:dut, tag: broken, dance: the_rendevouz) }
      visit_page_with_testing_query
      first('.search-ex-op').select('compare')
      find_all('.search-ex-op', count: 3)[1].select('tag')
      dances.each do |dance|
        if dance.id == call_me.id
          expect(page).to have_link(dance.title)
        else
          expect(page).to_not have_link(dance.title)
        end
      end
      select '1'
      dances.each do |dance|
        expect(page).to_not have_link(dance.title)
      end
      select 'please review'
      dances.each do |dance|
        if dance.id == the_rendevouz.id
          expect(page).to have_link(dance.title)
        else
          expect(page).to_not have_link(dance.title)
        end
      end
    end

    xit 'count-matches and compare filters' do
      dances
      visit_page_with_testing_query
      first('.search-ex-op').select('compare')
      find_all('.search-ex-op', count: 3)[1].select('count matches')
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
      visit_page_with_testing_query
      first('.search-ex-op').select('&')
      select('chain')
      expect(page).to have_css("#debug-lisp", text: '[ "&", [ "figure", "chain" ], [ "progression" ] ]', visible: false)
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

      xit 'parameters' do
        dances
        visit_page_with_testing_query
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

  def tag_all_dances(tag: FactoryGirl.create(:tag, :verified), user: FactoryGirl.create(:user))
    Dance.all.each do |dance|
      FactoryGirl.create(:dut, dance: dance, tag: tag, user: user)
    end
  end
end
