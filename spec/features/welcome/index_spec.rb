# coding: utf-8
require 'rails_helper'
require 'login_helper'

describe 'Welcome page', js: true do
  let (:dance) {FactoryGirl.create(:dance)}

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
      dance2 = FactoryGirl.create(:dance, title: "The First Dance", updated_at: DateTime.now + 1.minute)
      dance3 = FactoryGirl.create(:dance, title: "The Last Dance", updated_at: DateTime.now - 1.minute)
      visit '/'
      expect(page).to have_content(/#{dance2.title}.*#{dance.title}.*#{dance3.title}/)
    end

    it 'shows only dances visible to current user' do
      with_login do |user|
        dance2 = FactoryGirl.create(:dance, title: "this dance should be visible", publish: false, user: user)
        dance3 = FactoryGirl.create(:dance, title: "this dance should be invisible", publish: false)
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


      it "clicking 'add' insert a figure filter that responds to change events" do
        expect(page).to have_css('.figure-filter', count: 2)
        expect(page).to have_css('.figure-move', count: 1)
        click_button('Add')
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

      it 'change from empty-and to none'
      it 'change from double-and to none'
      it 'change from figure to none'
      it 'change from figure to and'
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
