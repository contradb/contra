# coding: utf-8
=begin
  __ _       _                                    _ 
 / _| | __ _| | ___   _   ___ _ __   ___  ___ ___| |
| |_| |/ _` | |/ / | | | / __| '_ \ / _ \/ __/ __| |
|  _| | (_| |   <| |_| | \__ \ |_) |  __/ (__\__ \_|
|_| |_|\__,_|_|\_\\__, | |___/ .__/ \___|\___|___(_)
                  |___/      |_|                    

The specs in this file are flaky, showing false reds. Run them a couple times. -dm 10-08-2017
=end



require 'rails_helper'
require 'login_helper'

describe 'Welcome page', js: true do
  let (:dances) {[:dance, :box_the_gnat_contra, :call_me].map {|d| FactoryGirl.create(d)}}
  it 'has a link to help on filters' do
    visit '/'
    expect(page).to have_link('', href: "https://github.com/dcmorse/contra/wiki/Dance-Figure-Filters")
  end

  context 'datatable' do
    let (:dance) {FactoryGirl.create(:box_the_gnat_contra)}
    it 'displays dance columns' do
      dance
      visit '/'
      expect(page).to have_link(dance.title, href: dance_path(dance))
      expect(page).to have_link(dance.choreographer.name, href: choreographer_path(dance.choreographer))
      expect(page).to have_link(dance.user.name, href: user_path(dance.user))
      expect(page).to have_text(dance.created_at.strftime('%Y-%m-%d'))
    end

    it 'displays in descencing updated_at order by default' do
      dance
      dance2 = FactoryGirl.create(:box_the_gnat_contra, title: "The First Dance", updated_at: DateTime.now + 1.minute)
      dance3 = FactoryGirl.create(:box_the_gnat_contra, title: "The Last Dance", updated_at: DateTime.now - 1.minute)
      visit '/'
      expect(page).to have_content(/#{dance2.title}.*#{dance.title}.*#{dance3.title}/)
    end

    it 'shows only dances visible to current user' do
      with_login do |user|
        dance2 = FactoryGirl.create(:box_the_gnat_contra, title: "this dance should be visible", publish: false, user: user)
        dance3 = FactoryGirl.create(:box_the_gnat_contra, title: "this dance should be invisible", publish: false)
        visit '/'
        expect(page).to have_content(dance2.title)
        expect(page).to_not have_content(dance3.title)
      end
    end

    it 'figure filter is initially just one figure set to wildcard' do
      visit '/'
      expect(page).to have_css("#figure-filter-root>.figure-filter-op")
      expect(find("#figure-filter-root>.figure-filter-op").value).to eq('figure')
      expect(page).to have_css("#figure-filter-root>.figure-filter-move")
      expect(find("#figure-filter-root>.figure-filter-move").value).to eq('*')
    end

    it "changing figure filter from 'figure' to 'and' installs two subfilters" do
      visit '/'
      select('and')
      expect(page).to have_css('.figure-filter', count: 3)
      expect(page).to have_css('.figure-filter-move', count: 2)
    end

    it "Rory O'Moore" do
      rory = FactoryGirl.create(:dance_with_a_rory_o_moore)
      box = FactoryGirl.create(:box_the_gnat_contra)
      visit '/'
      select "Rory O'Moore"
      expect(page).to_not have_content(box.title) # js wait
      expect(page).to have_content(rory.title)
      expect(rory.title).to eq("Just Rory")
    end

    describe 'figure filter machinantions' do
      before (:each) do
        dances
        visit '/'
        # get down to (and (filter '*')):
        select('and')
        all('.figure-filter-remove').last.click
      end
      
      it 'the precondition of all these other tests is fulfilled' do
        expect(page).to have_css('.figure-filter', count: 2)
        expect(page).to have_css('.figure-filter-move', count: 1)
        expect(page).to have_css("#figure-filter-root>.figure-filter-op") # js wait for...
        expect(find("#figure-filter-root>.figure-filter-op").value).to eq('and')
        expect(find("#figure-filter-root>.figure-filter .figure-filter-op").value).to eq('figure')
        expect(find("#figure-filter-root>.figure-filter .figure-filter-move").value).to eq('*')
        expect(page).to have_content('Call Me')
        expect(page).to have_content('Box the Gnat Contra')
        expect(page).to have_content('The Rendevouz')
      end

      it "changing figure changes values" do
        select('circle')

        expect(page).to have_content('The Rendevouz')
        expect(page).to_not have_content('Box the Gnat Contra')
        expect(page).to have_content('Call Me')
      end

      it "clicking 'add and' inserts a figure filter that responds to change events" do
        expect(page).to have_css('.figure-filter', count: 2)
        expect(page).to have_css('.figure-filter-move', count: 1)
        click_button('add and')
        expect(page).to have_css('.figure-filter', count: 3)
        expect(page).to have_css('.figure-filter-move', count: 2)
        all('.figure-filter-move').first.select('chain')
        all('.figure-filter-move').last.select('circle')

        expect(page).to have_content('Call Me')
        expect(page).to_not have_content('Box the Gnat Contra')
        expect(page).to_not have_content('The Rendevouz')
      end

      it "changing from 'and' to 'figure' purges subfilters and installs a new working move select" do
        select('circle')        # rendevous and call me
        expect(page).to have_css('.figure-filter', count: 2)
        expect(page).to have_css('.figure-filter-move', count: 1)
        first('.figure-filter-op').select('figure')
        select('chain')
        expect(page).to have_css('.figure-filter', count: 1)
        expect(page).to have_css('.figure-filter-move', count: 1)
        expect(page).to_not have_content('The Rendevouz')
        expect(page).to have_content('Box the Gnat Contra')
        expect(page).to have_content('Call Me')
      end

      it "change from an empty 'or' to 'no'" do
        all('.figure-filter-op').last.select('or');
        expect(page).to have_css('.figure-filter-op', count: 4)
        expect(page).to have_css('.figure-filter', count: 4)
        expect(page).to have_css('.figure-filter-add', count: 2)
        expect(page).to have_css('.figure-filter-move', count: 2)
        all('.figure-filter-remove').last.click
        expect(page).to have_css('.figure-filter', count: 3) # css wait
        all('.figure-filter-remove').last.click
        expect(page).to have_css('.figure-filter', count: 2) # css wait
        all('.figure-filter-op').last.select('no');
        expect(page).to have_css('.figure-filter', count: 3) # <- the main point here
      end

      it "change from binary 'and' to 'no'" do
        click_button('add and')
        all('.figure-filter-move').first.select('chain')
        all('.figure-filter-move').last.select('circle')
        expect(page).to_not have_content('The Rendevouz')
        expect(page).to_not have_content('Box the Gnat Contra')
        expect(page).to have_content('Call Me')
        all('.figure-filter-op').first.select('no'); # have no chain
        expect(page).to have_content('The Rendevouz')
        expect(page).to_not have_content('Box the Gnat Contra')
        expect(page).to_not have_content('Call Me')
      end

      it "change from 'figure' to 'no'" do
        # now we're ['and', ['figure', '*']]
        first('.figure-filter-op').select('figure')
        # now we're just ['figure', '*']
        select('no')
        # now we're ['no', ['figure', '*']]
        select('circle')
        # now we're ['no', ['figure', 'circle']]
        expect(page).to_not have_content('The Rendevouz')
        expect(page).to have_content('Box the Gnat Contra')
        expect(page).to_not have_content('Call Me')
      end

      it "change from 'figure' to 'or'" do
        all('.figure-filter-op').last.select('or')
        expect(page).to have_css('.figure-filter', count: 4)
        expect(page).to have_css('.figure-filter-add', count: 2)
        expect(find("#figure-query-buffer", visible: false).value).to eq('["and",["or",["figure","*"],["figure","*"]]]')
      end

      it "it adds/removes 'add' button depending on arity of the filter, and 'add' button works" do
        expect(page).to have_css('.figure-filter-add', count: 1)
        all('.figure-filter-op').first.select('no')
        expect(page).to have_css('.figure-filter-add', count: 0)
        all('.figure-filter-op').first.select('and')
        expect(page).to have_css('.figure-filter-add', count: 1)
        expect(page).to have_css('.figure-filter', count: 3)
        click_button('add and')
        expect(page).to have_css('.figure-filter', count: 4)
      end

      describe 'filter remove button' do
        it "root filter does not have a remove button" do
          expect(page).to_not have_css('#figure-filter-root > button.figure-filter-remove')
        end

        it "initial subfilter has a working remove button" do
          expect(page).to have_css('.figure-filter > button.figure-filter-remove', count: 1)
          find('.figure-filter-remove').click
          expect(page).to have_css('.figure-filter', count: 1)
        end

        it "another subfilter has a working remove button" do
          puts 'this is the hot spec' # if they don't press '...' then don't include those params at all
          select('circle')
          click_button('add and')   # adds a '*'
          expect(page).to have_css('.figure-filter > button.figure-filter-remove', count: 2)
          all('.figure-filter-remove').last.click
          expect(page).to have_css('.figure-filter', count: 2)
          expect(find("#figure-query-buffer", visible: false).value).to eq('["and",["figure","circle"]]')
        end

        it "changing my op still allows my remove button" do # this was a bug at one point
          all('.figure-filter-op').last.select('or')
          expect(page).to have_css('#figure-filter-root > .figure-filter > .figure-filter-remove')
          expect(page).to have_css('.figure-filter-remove', count: 3)
        end

        it "changing my op removes illegal remove buttons among my children, and adds them back in when they are legal" do
          first('.figure-filter-op').select('no')
          # [no, [figure *]]
          expect(page).to_not have_css('.figure-filter-remove') # remove illegal X buttons
          first('.figure-filter-op').select('and')
          expect(page).to have_css('#figure-filter-root > .figure-filter > .figure-filter-remove') # re-add X button
          expect(page).to have_css('.figure-filter-remove', count: 2)
        end
      end

      describe 'figure query sentence' do
        # "figure: chain" => "dances with a chain"
        # "no (figure: chain)" => "dances with no chain"
        # "no ((figure: chain) or (figure: hey))" => "dances with no chain or hey"
        it 'works with precondition' do
          expect(page).to have_content('dances with any figure')
        end
      end
    end

    describe 'figure ... button' do
      before (:each) do
        visit '/'
      end

      it "is visible initially, when figure is 'any figure'" do
        expect(page).to have_button('...')
      end

      it 'changing figure filter hides this one but creates two more' do
        select('then')
        expect(page).to have_button('...', count: 2)
      end

      context 'color' do
        before (:each) do
          select('chain')        
        end

        it "does not have class 'figure-toggle' initially" do
          expect(page).to_not have_css('.figure-filter-ellipsis.ellipsis-expanded')
        end

        it "does have class 'figure-toggle' after click" do
          click_button '...'
          expect(page).to have_css('.figure-filter-ellipsis.ellipsis-expanded')
        end

        it "does not have class 'figure-toggle' after two clicks" do
          click_button '...'
          click_button '...'
          expect(page).to_not have_css('.figure-filter-ellipsis.ellipsis-expanded')
        end
      end

      context 'accordion' do
        it 'lurks invisibly' do
          expect(page).to_not have_css('.figure-filter-accordion')
          expect(page).to have_css('.figure-filter-accordion', visible: false)
        end

        it 'pops forth when clicked' do
          click_button('...') 
          expect(page).to have_css('.figure-filter-accordion', visible: true)
        end

        it "circle 4 places finds only 'The Rendevouz'" do
          dances
          select('circle')
          click_button('...')
          select('4 places')

          expect(find("#figure-query-buffer", visible: false).value).to eq('["figure","circle","*","360","*"]')

          expect(page).to have_content('The Rendevouz') # has circle left 3 & 4 places
          expect(page).to_not have_content('Box the Gnat Contra') # no circles
          expect(page).to_not have_content('Call Me') # has circle left 3 places
        end
      end
    end
  end
end
