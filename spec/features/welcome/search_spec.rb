# coding: utf-8

require 'rails_helper'

describe 'Search page', js: true do
  let (:now) { DateTime.now }
  it "works" do
    dances = 12.times.map {|i| FactoryGirl.create(:dance, title: "Dance #{i}.", created_at: now - i.hours)}
    visit(s_path)
    dances.each_with_index do |dance, i|
      to_probably = i < 10 ? :to : :to_not
      expect(page).send to_probably, have_link(dance.title, href: dance_path(dance))
      expect(page).send to_probably, have_link(dance.choreographer.name, href: choreographer_path(dance.choreographer_id))
    end
  end

  describe 'pagination' do
    def have_turn_page_button(*args)
      have_css(turn_page_button_css(*args))
    end

    def turn_page_button_css(label, disabled=false)
      "button[data-testid=#{label.inspect}]#{disabled ? '[disabled]' : ''}"
    end

    let! (:dances) { 52.times.map {|i| FactoryGirl.create(:dance, title: "dance-#{i}.", created_at: now - i.hours)} }
    it "turning pages" do
      visit(s_path)
      # first page
      10.times {|i| expect(page).to have_link("dance-#{i}.")}
      expect(page).to have_text('Showing 1 to 10 of 52 dances')
      expect(page).to have_turn_page_button('<<', disabled: true)# have_css('button[data-testid="<<"][disabled]')
      expect(page).to have_turn_page_button('<', disabled: true)
      expect(page).to have_turn_page_button('>')
      expect(page).to have_turn_page_button('>>')
      page.find(turn_page_button_css('>')).click
      # second page
      10.times {|i| expect(page).to have_link("dance-#{i+10}.")}
      expect(page).to have_text('Showing 11 to 20 of 52 dances')
      expect(page).to have_turn_page_button('<<')
      expect(page).to have_turn_page_button('<')
      expect(page).to have_turn_page_button('>')
      expect(page).to have_turn_page_button('>>')
      page.find(turn_page_button_css('<')).click
      # first page
      10.times {|i| expect(page).to have_link("dance-#{i}.")}
      expect(page).to have_text('Showing 1 to 10 of 52 dances')
      expect(page).to have_turn_page_button('<<', disabled: true)
      expect(page).to have_turn_page_button('<', disabled: true)
      expect(page).to have_turn_page_button('>')
      expect(page).to have_turn_page_button('>>')
      # third page via numeric input
      find('.page-number-entry').fill_in(with: '3') # third page
      10.times {|i| expect(page).to have_link("dance-#{i+20}.")}
      expect(page).to have_text('Showing 21 to 30 of 52 dances')
      expect(page).to have_turn_page_button('<<')
      expect(page).to have_turn_page_button('<')
      expect(page).to have_turn_page_button('>')
      expect(page).to have_turn_page_button('>>')
      page.find(turn_page_button_css('>>')).click
      # last (partial) page
      2.times {|i| expect(page).to have_link("dance-#{i+50}.")}
      expect(page).to have_text('Showing 51 to 52 of 52 dances')
      expect(page).to have_turn_page_button('<<')
      expect(page).to have_turn_page_button('<')
      expect(page).to have_turn_page_button('>', disabled: true)
      expect(page).to have_turn_page_button('>>', disabled: true)
      page.find(turn_page_button_css('<<')).click
      # first page
      10.times {|i| expect(page).to have_link("dance-#{i}.")}
      expect(page).to have_text('Showing 1 to 10 of 52 dances')
      expect(page).to have_turn_page_button('<<', disabled: true)
      expect(page).to have_turn_page_button('<', disabled: true)
      expect(page).to have_turn_page_button('>')
      expect(page).to have_turn_page_button('>>')
    end

    it "page size select menu" do
      visit(s_path)
      expect(page).to have_text("Showing 1 to 10 of 52 dances.")
      select('30')
      expect(page).to have_text("Showing 1 to 30 of 52 dances.")
      page.find(turn_page_button_css('>')).click
      expect(page).to have_text("Showing 31 to 52 of 52 dances.")
      (dances.length-30).times do |i|
        expect(page).to have_link("dance-#{i+30}.")
      end
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

  it "sentence displays how many search results match" do
    dbsize = 12
    dbsize.times.map {|i| FactoryGirl.create(:dance, created_at: now - i.hours)}
    visit(s_path)
    expect(page).to have_content("Showing 1 to 10 of #{dbsize} dances.")
    # TODO add more tests around changing the offset and count
  end
end
