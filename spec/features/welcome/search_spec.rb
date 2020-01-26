# coding: utf-8

require 'rails_helper'

describe 'Search page', js: true do
  let (:now) { DateTime.now }
  it "works" do
    dances = 12.times.map {|i| FactoryGirl.create(:dance, title: "Dance #{i}.", created_at: now - i.days)}
    visit(s_path)
    dances.each_with_index do |dance, i|
      to_probably = i < 10 ? :to : :to_not
      expect(page).send to_probably, have_link(dance.title, href: dance_path(dance))
      expect(page).send to_probably, have_link(dance.choreographer.name, href: choreographer_path(dance.choreographer_id))
      expect(page).send to_probably, have_text(dance.created_at.localtime.strftime("%-m/%-d/%Y"))
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

    describe 'matching figures column' do
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
  end

  describe "sorting" do
    it "clicking a header displays that column in descending order" do
      shuffled_ints = [7, 0, 10, 8, 9, 2, 11, 6, 3, 5, 1, 4]
      dances = shuffled_ints.map.with_index {|shuffled_int, i|
        FactoryGirl.create(:dance, title: "dance-#{shuffled_int.to_s.rjust(2, '0')}", created_at: now - i.hours)
      }
      dances_sorted = dances.dup.sort_by(&:title)
      visit(s_path)
      dances.each_with_index do |dance, i|
        expect(page).send(i < 10 ? :to : :to_not, have_text(dance.title))
      end
      expect(page).to_not have_css('th .glyphicon-sort-by-attributes')
      expect(page).to_not have_css('th .glyphicon-sort-by-attributes-alt')
      unsorted_dances_titles_regex = Regexp.new(dances.take(10).map(&:title).join('.*\n'))
      expect(page).to have_text(unsorted_dances_titles_regex)

      # first click makes it sort descending
      find('th', text: 'Title').click
      expect(page).to have_css('th .glyphicon-sort-by-attributes')
      expect(page).to_not have_css('th .glyphicon-sort-by-attributes-alt')
      dances_sorted.each_with_index do |dance, i|
        expect(page).send(i < 10 ? :to : :to_not, have_text(dance.title))
      end
      # we see we have the dances, but do we have them in order? dance-00, dance-01, ... dance-09
      first_ten_dances_titles_regex = Regexp.new(dances_sorted.take(10).map(&:title).join('.*\n'))
      expect(page).to have_text(first_ten_dances_titles_regex)

      # second click makes it sort ascending
      find('th', text: 'Title').click
      expect(page).to have_css('th .glyphicon-sort-by-attributes-alt')
      expect(page).to_not have_css('th .glyphicon-sort-by-attributes')
      dances_sorted.each_with_index do |dance, i|
        expect(page).send(i >= dances.length-10 ? :to : :to_not, have_text(dance.title))
      end
      # we see we have the dances, but do we have them in order? dance-12, dance-11, ... dance-02
      last_ten_dances_titles_regex = Regexp.new(dances_sorted.reverse.take(10).map(&:title).join('.*\n'))
      expect(page).to have_text(last_ten_dances_titles_regex)

      # third click returns to default sort (which is by descending created_at)
      find('th', text: 'Title').click
      expect(page).to_not have_css('th .glyphicon-sort-by-attributes-alt')
      expect(page).to_not have_css('th .glyphicon-sort-by-attributes')
      page.save_screenshot('/tmp/foo.png')
      dances.each_with_index do |dance, i|
        expect(page).send(i < 10 ? :to : :to_not, have_text(dance.title))
      end
      expect(page).to have_text(unsorted_dances_titles_regex)
    end

    it "no weird monkey business with client side sorting" do
      titles = ['40 Years of Penguin Pam', "A Crafty Wave", "24th of June"]
      dances = titles.map {|title| FactoryGirl.create(:dance, title: title)}
      titles_sorted = titles.dup.sort
      visit(s_path)
      find('th', text: 'Title').click
      expect(page).to have_text(Regexp.new(titles_sorted.join('.*\n')))
    end

    it "you can't sort by matching figures" do
      dances = [:dance, :box_the_gnat_contra, :call_me].each_with_index.map do |t, i|
        FactoryGirl.create(t, created_at: now - i.hours)
      end
      the_ordered_regexp = Regexp.new(dances.map(&:title).join('(?:.*\n)+'))
      visit(s_path)
      click_button 'Figures'
      expect(page).to have_content(the_ordered_regexp) # order is time-sorted
      find('th', text: 'Figures').click
      expect(page).to_not have_css('th .glyphicon-sort-by-attributes')
      expect(page).to_not have_css('th .glyphicon-sort-by-attributes-alt')
      expect(page).to have_content(the_ordered_regexp) # order is still time-sorted
    end

    it "sorting all columns (except matching figure) does not give error" do
      dances = [:dance, :box_the_gnat_contra, :call_me].each_with_index.map do |t, i|
        FactoryGirl.create(t, created_at: now - i.hours)
      end
      visit(s_path)
      columns = page.find_all(".toggle-vis-active").to_a + page.find_all(".toggle-vis-inactive").to_a
      column_names = columns.map(&:text)
      column_names_not_to_check = ['Figures']
      column_names_checked = column_names - column_names_not_to_check
      column_names_checked.each do |column_name|
        unless has_css?('.toggle-vis-active', text: column_name)
          click_button(column_name)
        end
        th = find('.dance-table-th', text: column_name)
        expect(th).to have_css('.glyphicon-sort')
        expect(th).to_not have_css('.glyphicon-sort-by-attributes')
        expect(th).to_not have_css('.glyphicon-sort-by-attributes-alt')
        th.click
        expect(th).to have_css('.glyphicon-sort-by-attributes')
        expect(th).to_not have_css('.glyphicon-sort')
        expect(th).to_not have_css('.glyphicon-sort-by-attributes-alt')
        th.click
        expect(th).to have_css('.glyphicon-sort-by-attributes-alt')
        expect(th).to_not have_css('.glyphicon-sort')
        expect(th).to_not have_css('.glyphicon-sort-by-attributes')
        th.click
        expect(th).to have_css('.glyphicon-sort')
        expect(th).to_not have_css('.glyphicon-sort-by-attributes')
        expect(th).to_not have_css('.glyphicon-sort-by-attributes-alt')
      end
    end
  end

  describe "filters" do
    describe "choreographer" do
      let(:dances) { [:dance, :box_the_gnat_contra, :call_me].map {|name| FactoryGirl.create(name)} }

      it "works" do
        call_me = dances.last
        dont_call_me = dances[0, dances.length-2]
        visit(s_path)
        find('.ez-choreographer-filter').fill_in(with: call_me.choreographer)
        dont_call_me.each do |dance|
          expect(page).to_not have_content(dance.title)
        end
      end
    end
  end
end
