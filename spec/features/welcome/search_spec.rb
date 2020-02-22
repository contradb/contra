# coding: utf-8

require 'rails_helper'

describe 'Search page', js: true do
  let (:now) { DateTime.now }
  it "works" do
    dances = 12.times.map {|i| FactoryGirl.create(:dance, title: "Dance #{i}.", created_at: now - i.days)}
    tag_all_dances
    visit(s_path)
    dances.each_with_index do |dance, i|
      to_probably = i < 10 ? :to : :to_not
      expect(page).send to_probably, have_link(dance.title, href: dance_path(dance))
      expect(page).send to_probably, have_link(dance.choreographer.name, href: choreographer_path(dance.choreographer_id))
      expect(page).send to_probably, have_link(dance.user.name, href: user_path(dance.user_id))
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
    before { tag_all_dances }
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
      tag_all_dances
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
      dances
      tag_all_dances
      with_login do |user|
        dances.each_with_index do |dance, i|
          publish = [:off, :sketchbook, :all][i]
          dance.update!(publish: publish, user: user)
        end
        visit(s_path)
        check_filter 'ez-entered-by-me'
        click_button 'Sharing'
        dances.each_with_index do |dance, i|
          publish_string = ['private', 'sketchbook', 'everywhere'][i]
          expect(page).to have_css('tr', text: /#{dance.title}.*#{publish_string}/)
        end
      end
    end

    describe 'matching figures column' do
      it 'whole dance' do
        dances
        tag_all_dances
        visit(s_path)
        expect(page).to_not have_css(:th, text: "Figures")
        expect(page).to_not have_content('whole dance')
        click_button 'Figures'
        expect(page).to have_css(:th, text: "Figures") # js wait
        expect(page).to have_content('whole dance', count: 3)
      end

      it 'some matches prints figures' do
        # TODO: update how we pass the filter when there's a user-facing way to send figure queries
        # 4NOW: stub the controller, heh heh -dm 01-30-2020
        expect_any_instance_of(Api::V1::DancesController).to receive(:filter).and_return(['figure', 'circle'])
        # mock
        dances
        tag_all_dances
        visit(s_path)
        click_button 'Figures'
        expect(page).to have_css('tr', text: /The Rendevouz.*\n?circle left 4 places\ncircle left 3 places/)
        expect(page).to have_css('tr', text: /Call Me.*\n?circle left 3 places/)
      end

      it 'matches print in dialect' do
        expect_any_instance_of(Api::V1::DancesController).to receive(:filter).and_return(['figure', 'do si do'])
        allow_any_instance_of(Api::V1::DancesController).to receive(:dialect).and_return(JSLibFigure.test_dialect)
        dances
        tag_all_dances
        visit(s_path)
        click_button 'Figures'
        expect(page).to have_css('tr', text: /The Rendevouz.*\n?ravens do si do 1½/)
      end
    end

    it "hook column is in dialect" do
      with_login do
        allow_any_instance_of(User).to receive(:dialect).and_return(JSLibFigure.test_dialect)
        dances
        dances.first.update!(hook: 'dreary gyre daytime')
        tag_all_dances
        visit(s_path)
        expect(page).to have_content('dreary darcy daytime')
      end
    end
  end

  it "sentence displays how many search results match" do
    dbsize = 12
    dbsize.times.map {|i| FactoryGirl.create(:dance, created_at: now - i.hours)}
    tag_all_dances
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
      tag_all_dances
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
      dances.each_with_index do |dance, i|
        expect(page).send(i < 10 ? :to : :to_not, have_text(dance.title))
      end
      expect(page).to have_text(unsorted_dances_titles_regex)
    end

    it "no weird monkey business with client side sorting" do
      titles = ['40 Years of Penguin Pam', "A Crafty Wave", "24th of June"]
      dances = titles.map {|title| FactoryGirl.create(:dance, title: title)}
      titles_sorted = titles.dup.sort
      tag_all_dances
      visit(s_path)
      find('th', text: 'Title').click
      expect(page).to have_text(Regexp.new(titles_sorted.join('.*\n')))
    end

    it "you can't sort by matching figures" do
      dances = [:dance, :box_the_gnat_contra, :call_me].each_with_index.map do |t, i|
        FactoryGirl.create(t, created_at: now - i.hours)
      end
      the_ordered_regexp = Regexp.new(dances.map(&:title).join('(?:.*\n)+'))
      tag_all_dances
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
      tag_all_dances
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

  describe "ez-filters" do
    let(:user) { FactoryGirl.create(:user) }

    describe "choreographer" do
      let(:dances) { [:dance, :box_the_gnat_contra, :call_me].map {|name| FactoryGirl.create(name)} }

      it "works" do
        call_me = dances.last
        dont_call_me = dances[0, dances.length-2]
        visit(s_path)
        with_filters_excursion { find('.ez-choreographer-filter').fill_in(with: call_me.choreographer) }
        dont_call_me.each do |dance|
          expect(page).to_not have_content(dance.title)
        end
      end
    end

    describe "hook" do
      it "works on the word 'easy'" do
        easy_dance = FactoryGirl.create(:dance, hook: "so easy-peazy", title: "Mr. Toad's Wild Ride")
        hard_dance = FactoryGirl.create(:dance, hook: "complicated", title: "hard mcguard" )
        tag_all_dances
        visit(s_path)
        with_filters_excursion { find('.ez-hook-filter').fill_in(with: "easy") }
        expect(page).to_not have_content(hard_dance.title)
        expect(page).to have_content(easy_dance.title)
      end

      it "works with dialect" do
        lark_dance = FactoryGirl.create(:dance, hook: "gentlespoons can go fish", title: "abcde")
        wombat_dance = FactoryGirl.create(:dance, hook: "wombats can go fish", title: "tuvwxyz")
        tag_all_dances
        allow_any_instance_of(User).to receive(:dialect).and_return(JSLibFigure.test_dialect)
        with_login(user: user) do
          visit(s_path)
          with_filters_excursion { find('.ez-hook-filter').fill_in(with: "larks") }
          expect(page).to_not have_content(wombat_dance.title)
          expect(page).to have_content(lark_dance.title)
        end
      end
    end

    describe "verified" do
      let! (:dances) do
        %w(unverified yaverified verified-by-me).map {|s| FactoryGirl.create(:dance, title: s)}
      end
      let (:verified) { FactoryGirl.create(:tag, :verified) }
      let! (:dut_somebody_else) { FactoryGirl.create(:dut, tag: verified, dance: dances[1]) }
      let! (:dut_by_me) { FactoryGirl.create(:dut, tag: verified, dance: dances[2], user: user) }
      let (:unverified_dance) { dances[0] }
      let (:verified_dance) { dances[1] }
      let (:verified_by_me_dance) { dances[2] }

      it "'verified' and 'not verified' checkboxes work" do
        visit(s_path)
        expect_dances(verified: true, not_verified: false) # the default
        check_filter 'ez-not-verified'
        expect_dances(verified: true, not_verified: true)
        uncheck_filter 'ez-verified', match: :prefer_exact
        expect_dances(verified: false, not_verified: true)
        uncheck_filter 'ez-not-verified'
        expect_dances(verified: false, not_verified: false)
        check_filter 'ez-verified', match: :prefer_exact
        expect_dances(verified: true, not_verified: false)
      end

      it "'verified by me' and 'not verified by me' checkboxes work" do
        with_login(user: user) do
          visit(s_path)
          expect_dances(verified: true) # the default
          uncheck_filter 'ez-verified', match: :prefer_exact
          expect_dances()
          check_filter 'ez-not-verified-by-me'
          expect_dances(not_verified_by_me: true)
          check_filter 'ez-verified-by-me'
          expect_dances(verified_by_me: true, not_verified_by_me: true)
          uncheck_filter 'ez-not-verified-by-me'
          expect_dances(verified_by_me: true)
          uncheck_filter 'ez-verified-by-me'
          expect_dances()
        end
      end

      it "'verified by me' and 'not verified by me' checkboxes are disabled when not logged in" do
        visit(s_path)
        with_filters_excursion do
          expect(page.find("#ez-verified-by-me")).to be_disabled
          expect(page.find("#ez-not-verified-by-me")).to be_disabled
        end
      end

      it "'verified by me' and 'not verified by me' checkboxes are hidden when not logged in on phones"

      def expect_dances(verified: false,
                        not_verified: false,
                        verified_by_me: false,
                        not_verified_by_me: false)
        expect(page).send(not_verified || not_verified_by_me ? :to : :to_not, have_content(unverified_dance.title))
        expect(page).send(verified || not_verified_by_me ? :to : :to_not, have_content(verified_dance.title))
        expect(page).send(verified || verified_by_me ? :to : :to_not, have_content(verified_by_me_dance.title))
      end
    end

    describe "shared" do
      let(:user2) { FactoryGirl.create(:user) }
      let!(:dances) { [{user: user2, publish: :off},
                       {user: user2, publish: :sketchbook},
                       {user: user2, publish: :all},
                       {user: user, publish: :off},
                       {user: user, publish: :sketchbook},
                       {user: user, publish: :all}
                      ].each_with_index.map {|props, i| FactoryGirl.create(:dance, title: "Dance-#{i}", **props)}}
      before { tag_all_dances }
      let(:private_checkbox_css) { "#ez-private" }
      
      it "shared, sketchbooks, and entered-by-me checkboxes work" do
        with_login(user: user) do
          visit(s_path)
          6.times {|i| expect(page).send(i.in?([2,5]) ? :to : :to_not, have_content(dances[i].title))}
          check_filter 'ez-sketchbooks'
          6.times {|i| expect(page).send(i.in?([1,2,4,5]) ? :to : :to_not, have_content(dances[i].title))}
          uncheck_filter 'ez-shared'
          6.times {|i| expect(page).send(i.in?([1,4]) ? :to : :to_not, have_content(dances[i].title))}
          check_filter 'ez-entered-by-me'
          6.times {|i| expect(page).send(i.in?([1,3,4,5]) ? :to : :to_not, have_content(dances[i].title))}
          uncheck_filter 'ez-sketchbooks'
          6.times {|i| expect(page).send(i.in?([3,4,5]) ? :to : :to_not, have_content(dances[i].title))}
          check_filter 'ez-shared'
          6.times {|i| expect(page).send(i.in?([2,3,4,5]) ? :to : :to_not, have_content(dances[i].title))}
        end
      end

      it "Admins can use the 'private' checkbox" do
        with_login(admin: true) do
          visit(s_path)
          with_filters_excursion do
            expect(page).to have_css(private_checkbox_css)
            check 'ez-private'
          end
          6.times {|i| expect(page).send(i.in?([0,2,3,5]) ? :to : :to_not, have_content(dances[i].title))}
        end
      end

      it "Doesn't clutter the interface with 'private' for regular users" do
        with_login(user: user) do
          visit(s_path)
          6.times {|i| expect(page).send(i.in?([2,5]) ? :to : :to_not, have_content(dances[i].title))} # js wait
          with_filters_excursion { expect(page).to_not have_css(private_checkbox_css) }
        end
      end

      it "'entered by me' checkbox is disabled when not logged in" do
        visit(s_path)
        with_filters_excursion { expect(page.find("#ez-entered-by-me")).to be_disabled }
      end
    end

    describe "formation" do
      it "works" do
        becket = FactoryGirl.create(:call_me)
        improper = FactoryGirl.create(:box_the_gnat_contra)
        wingnut = FactoryGirl.create(:dance, start_type: "I'm a user. Guess I'll make up something for this one dance! Durdee dur dur!")
        tag_all_dances
        expect(becket.start_type).to eq('Becket ccw')
        expect(improper.start_type).to eq('improper')
        visit(s_path)
        expect(page).to have_content(becket.title)
        expect(page).to have_content(improper.title)
        expect(page).to have_content(wingnut.title)
        uncheck_filter 'ez-improper'
        expect(page).to_not have_content(improper.title)
        expect(page).to have_content(becket.title)
        expect(page).to have_content(wingnut.title)
        uncheck_filter 'ez-becket'
        expect(page).to_not have_content(improper.title)
        expect(page).to_not have_content(becket.title)
        expect(page).to have_content(wingnut.title)
        check_filter 'ez-improper'
        expect(page).to have_content(improper.title)
        expect(page).to_not have_content(becket.title)
        expect(page).to have_content(wingnut.title)
        check_filter 'ez-becket'
        expect(page).to have_content(improper.title)
        expect(page).to_not have_content(becket.title)
        uncheck_filter 'ez-everything-else'
        expect(page).to_not have_content(wingnut.title)
        expect(page).to have_content(improper.title)
        expect(page).to have_content(becket.title)
      end
    end
  end

  describe 'tabs' do
    it 'work' do
      results_tab_label = /0 dances/i
      visit(s_path)
      expect(page).to have_css('.search-tabs button.selected', text: results_tab_label)
      expect(page).to have_css('.search-tabs button.selected', count: 1)
      expect(page).to have_css('.dances-table-react')           # results page
      expect(page).to_not have_css('h4', text: 'Choreographer') # filter page
      expect(page).to_not have_content('Coming Soon!')          # figures page
      expect(page).to_not have_content('Coming Eventually!')    # program page
      click_on 'filters'
      expect(page).to have_css('.search-tabs button.selected', text: 'filters')
      expect(page).to have_css('.search-tabs button.selected', count: 1)
      expect(page).to_not have_css('.dances-table-react')       # results page
      expect(page).to have_css('h4', text: 'Choreographer')     # filter page
      expect(page).to_not have_content('Coming Soon!')          # figures page
      expect(page).to_not have_content('Coming Eventually!')    # program page
      click_on 'figures'
      expect(page).to have_css('.search-tabs button.selected', text: 'figures')
      expect(page).to have_css('.search-tabs button.selected', count: 1)
      expect(page).to_not have_css('.dances-table-react')       # results page
      expect(page).to_not have_css('h4', text: 'Choreographer') # filter page
      expect(page).to have_content('Coming Soon!')              # figures page
      expect(page).to_not have_content('Coming Eventually!')    # program page
      click_on_results_tab
      expect(page).to have_css('.search-tabs button.selected', text: results_tab_label)
      expect(page).to have_css('.search-tabs button.selected', count: 1)
      expect(page).to have_css('.dances-table-react')           # results page
      expect(page).to_not have_css('h4', text: 'Choreographer') # filter page
      expect(page).to_not have_content('Coming Soon!')          # figures page
      expect(page).to_not have_content('Coming Eventually!')    # program page
      click_on 'program'
      expect(page).to have_css('.search-tabs button.selected', text: 'program')
      expect(page).to have_css('.search-tabs button.selected', count: 1)
      expect(page).to_not have_css('.dances-table-react')       # results page
      expect(page).to_not have_css('h4', text: 'Choreographer') # filter page
      expect(page).to_not have_content('Coming Soon!')          # figures page
      expect(page).to have_content('Coming Eventually!')        # program page
    end

    it 'result tab displays number of matches' do
      %i(dance call_me box_the_gnat_contra).each {|d| FactoryGirl.create(d)}
      tag_all_dances
      visit(s_path)
      expect(page).to have_css('.search-tabs button', text: /3 dances/i)
    end
  end

  def tag_all_dances(tag: FactoryGirl.create(:tag, :verified), user: FactoryGirl.create(:user))
    Dance.all.each do |dance|
      FactoryGirl.create(:dut, dance: dance, tag: tag, user: user)
    end
  end

  def with_filters_excursion(&block)
    click_on 'filters'
    block.call
    click_on_results_tab
    expect(page).to have_css('.dances-table-react') # wait for table to pop in before, say, testing for the absence of an element
  end

  def click_on_results_tab
    find('.search-tabs button', text: /[0-9]+ dances?/i).click
  end

  def check_filter(*check_args)
    with_filters_excursion { check(*check_args) }
  end

  def uncheck_filter(*uncheck_args)
    with_filters_excursion { uncheck(*uncheck_args) }
  end
end
