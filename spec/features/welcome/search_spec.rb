# coding: utf-8

require 'rails_helper'

describe 'Search page', js: true do
  it "works" do
    dances = 12.times.map {|i| FactoryGirl.create(:dance, title: "Dance #{i}.")}
    visit(s_path)
    dances.each_with_index do |dance, i|
      to_probably = i < 10 ? :to : :to_not
      expect(page).send to_probably, have_link(dance.title, href: dance_path(dance))
      expect(page).send to_probably, have_link(dance.choreographer.name, href: choreographer_path(dance.choreographer_id))
    end
  end
  describe 'columns' do
    let (:dances) {[:dance, :box_the_gnat_contra, :call_me].map {|d| FactoryGirl.create(d)}}
    it "Clicking vis toggles buttons cause columns to disappear" do
      dances
      visit(s_path)
      %w[Title Choreographer Formation Hook User Entered].each do |col|
        expect(page).to have_css('.dances-table-react th', text: col)
        expect(page).to have_css('button.toggle-vis-active', text: col)
        expect(page).to_not have_css('button.toggle-vis-inactive', text: col)
        click_button col
        expect(page).to_not have_css('.dances-table-react th', text: col)
        expect(page).to have_css('button.toggle-vis-inactive', text: col)
        expect(page).to_not have_css('button.toggle-vis-active', text: col)
        click_button col
        expect(page).to have_css('.dances-table-react th', text: col)
        expect(page).to have_css('button.toggle-vis-active', text: col)
        expect(page).to_not have_css('button.toggle-vis-inactive', text: col)
      end
      %w[Updated Sharing Figures].each do |col|
        expect(page).to_not have_css('.dances-table-react th', text: col)
        expect(page).to_not have_css('button.toggle-vis-active', text: col)
        expect(page).to  have_css('button.toggle-vis-inactive', text: col)
        click_button col
        expect(page).to have_css('.dances-table-react th', text: col)
        expect(page).to_not have_css('button.toggle-vis-inactive', text: col)
        expect(page).to have_css('button.toggle-vis-active', text: col)
        click_button col
        expect(page).to_not have_css('.dances-table-react th', text: col)
        expect(page).to have_css('button.toggle-vis-inactive', text: col)
        expect(page).to_not have_css('button.toggle-vis-active', text: col)
      end
    end

    it 'published column cells' do
      with_login do |user|
        dances.each_with_index do |dance, i|
          publish = [:off, :link, :all][i]
          publish_string = ['myself', 'link', 'everyone'][i]
          dance.update!(publish: publish, user: user)
          visit(s_path)
          click_button 'Sharing'
          expect(page).to have_css('tr', text: /#{dance.title}.*#{publish_string}/)
        end
      end
    end

    describe 'figures column' do
      it 'whole dance' do
        dances
        visit(s_path)
        expect(page).to_not have_css(:th, text: "Figures")
        expect(page).to_not have_content('whole dance')
        click_button 'Figures'
        expect(page).to have_css(:th, text: "Figures") # js wait
        expect(page).to have_content('whole dance', count: 3)
      end

      it 'some matches prints figures' do
        expect_any_instance_of(Api::V1::DancesController).to receive(:filter).and_return(['figure', 'circle'])
        # mock
        dances
        visit(s_path)
        click_button 'Figures'
        expect(page).to have_css('tr', text: /The Rendevouz.*\n?circle left 4 places\ncircle left 3 places/)
        expect(page).to have_css('tr', text: /Call Me.*\n?circle left 3 places/)
      end
    end
  end
end
