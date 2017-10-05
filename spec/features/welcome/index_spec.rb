# coding: utf-8
require 'rails_helper'
require 'login_helper'

describe 'Welcome page', js: true do
  let (:dance) {FactoryGirl.create(:box_the_gnat_contra)}

  context 'datatable' do
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

    describe 'figure filter' do
      let (:dances) {[:dance, :box_the_gnat_contra, :call_me].map {|d| FactoryGirl.create(d)}}
      before (:each) do
        dances
        visit '/'
        # install an and, with one figure in it
      end
      
      it 'the test filter is present and works' do

        expect(page).to have_css("#figure-filter-root>.figure-filter-op") # js wait for...
        expect(find("#figure-filter-root>.figure-filter-op").value).to eq('and')

        expect(find("#figure-filter-root>.figure-filter .figure-filter-op").value).to eq('figure')
        expect(find("#figure-filter-root>.figure-filter .figure-move").value).to eq('chain')

        expect(page).to have_content('Call Me')
        expect(page).to have_content('Box the Gnat Contra')
        expect(page).to_not have_content('The Rendevouz')
      end

      it "changing figure changes values" do
        expect(page).to have_css('.figure-filter', count: 2)
        expect(page).to have_css('.figure-move', count: 1)
        select('circle')

        expect(page).to have_content('The Rendevouz')
        expect(page).to_not have_content('Box the Gnat Contra')
        expect(page).to have_content('Call Me')
      end


      it "clicking 'add and' inserts a figure filter that responds to change events" do
        expect(page).to have_css('.figure-filter', count: 2)
        expect(page).to have_css('.figure-move', count: 1)
        click_button('add and')
        expect(page).to have_css('.figure-filter', count: 3)
        expect(page).to have_css('.figure-move', count: 2)
        all('.figure-move').last.select('circle') # first select is 'chain'

        expect(page).to have_content('Call Me')
        expect(page).to_not have_content('Box the Gnat Contra')
        expect(page).to_not have_content('The Rendevouz')
      end


      it "changing from 'and' to 'figure' purges subfilters and installs a new working move select" do
        select('circle')        # rendevous and call me
        expect(page).to have_css('.figure-filter', count: 2)
        expect(page).to have_css('.figure-move', count: 1)
        first('.figure-filter-op').select('figure')
        expect(page).to have_css('.figure-filter', count: 1)
        expect(page).to have_css('.figure-move', count: 1)
        expect(page).to_not have_content('The Rendevouz')
        expect(page).to have_content('Box the Gnat Contra')
        expect(page).to have_content('Call Me')
      end

      it 'change from empty-or to none' do
        all('.figure-filter-op').last.select('or');
        expect(page).to have_css('.figure-filter-op', count: 2) # css wait
        expect(page).to have_css('.figure-filter', count: 2)
        expect(page).to have_css('.figure-filter-add', count: 2)
        expect(page).to_not have_css('.figure-move')
      end

      it 'change from double-and to none' do
        click_button('add and')
        all('.figure-move').last.select('circle') # first select is 'chain'
        expect(page).to_not have_content('The Rendevouz')
        expect(page).to_not have_content('Box the Gnat Contra')
        expect(page).to have_content('Call Me')
        all('.figure-filter-op').first.select('none'); # have none chain
        expect(page).to have_content('The Rendevouz')
        expect(page).to_not have_content('Box the Gnat Contra')
        expect(page).to_not have_content('Call Me')
      end

      it 'change from figure to none' do
        # now we're ['and', ['figure', 'chain']]
        first('.figure-filter-op').select('figure')
        # now we're just ['figure', 'chain']
        select('none')
        # now we're ['none', ['figure', something]]
        select('circle')
        # now we're ['none', ['figure', 'circle']]
        expect(page).to_not have_content('The Rendevouz')
        expect(page).to have_content('Box the Gnat Contra')
        expect(page).to_not have_content('Call Me')
      end

      it 'change from figure to or' do
        all('.figure-filter-op').last.select('or')
        expect(page).to have_css('.figure-filter', count: 2)
        expect(page).to have_css('.figure-filter-add', count: 2)
        expect(find("#query-buffer", visible: false).value).to eq('["and",["or"]]')
      end

      it "it adds/removes 'add' button depending on arity of the filter" do
        expect(page).to have_css('.figure-filter-add', count: 1)
        all('.figure-filter-op').first.select('none')
        expect(page).to have_css('.figure-filter-add', count: 0)
        all('.figure-filter-op').first.select('and')
        expect(page).to have_css('.figure-filter-add', count: 1)
        click_button('add and')
        expect(page).to have_css('.figure-filter', count: 3)
      end

      describe 'filter remove button' do
        it "root filter does not have a remove button" do
          expect(page).to_not have_css('#figure-filter-root > button.figure-filter-remove')
        end

        it "initial subfilter has a working remove button" do
          expect(page).to have_css('.figure-filter > button.figure-filter-remove', count: 1)
          click_button('X')
          expect(page).to have_css('.figure-filter', count: 1)
        end

        it "another subfilter has a working remove button" do
          select('circle')
          click_button('add and')   # adds a chain
          expect(page).to have_css('.figure-filter > button.figure-filter-remove', count: 2)
          all('.figure-filter-remove').last.click
          expect(page).to have_css('.figure-filter', count: 2)
          expect(find("#query-buffer", visible: false).value).to eq('["and",["figure","circle"]]')
        end

        it "changing my op still allows my remove button" do # this was a bug at one point
          all('.figure-filter-op').last.select('or')
          expect(page).to have_css('#figure-filter-root > .figure-filter > .figure-filter-remove')
          expect(page).to have_css('.figure-filter-remove', count: 1)
        end

        it "changing my op removes illegal remove buttons among my children, and adds them back in when they are legal" do
          first('.figure-filter-op').select('none')
          # [none, [figure chain]]
          expect(page).to_not have_css('.figure-filter-remove') # remove illegal X buttons
          first('.figure-filter-op').select('and')
          expect(page).to have_css('#figure-filter-root > .figure-filter > .figure-filter-remove') # re-add X button
          expect(page).to have_css('.figure-filter-remove', count: 1)
        end
      end
    end
  end

  context 'link cloud' do
    it 'has links to sluggified figures' do
      visit '/'
      expect(page).to have_link('swing', href: figure_path('swing'))
      expect(page).to have_link('do si do', href: figure_path('do-si-do'))
      expect(page).to have_link("Rory O'Moore", href: figure_path('rory-omoore'))
    end
  end
end
