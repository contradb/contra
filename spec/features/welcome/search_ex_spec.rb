# coding: utf-8

require 'rails_helper'

describe "SearchExEditor's search results", js: true do
  let (:dances) {
    dances = [:dance, :box_the_gnat_contra, :call_me].map {|d| FactoryGirl.create(d)}
    tag_all_dances
    dances
  }

  let (:dance) {FactoryGirl.create(:box_the_gnat_contra, created_at: DateTime.now - 10.years, updated_at: DateTime.now - 1.week, publish: :all)}

  it 'shows only dances visible to current user' do
    with_login do |user|
      dance2 = FactoryGirl.create(:box_the_gnat_contra, title: "this dance should be visible", publish: :off, user: user)
      dance3 = FactoryGirl.create(:box_the_gnat_contra, title: "this dance should be invisible", publish: :off)
      tag_all_dances
      visit search_path
      check('ez-sketchbooks')
      check('ez-entered-by-me')
      wait_to_load
      expect(page).to have_content(dance2.title)
      expect(page).to_not have_content(dance3.title)
    end
  end

  it 'figure filter is initially just one figure set to wildcard' do
    visit search_path
    expect(page).to have_css("#search-ex-root .search-ex-op", count: 1)
    expect(find("#search-ex-root .search-ex-op").value).to eq('figure')
    expect(page).to have_css("#search-ex-root .search-ex-move")
    expect(find("#search-ex-root .search-ex-move").value).to eq('*')
  end

  it "changing figure filter from 'figure' to 'and' installs two subfilters" do
    visit search_path
    select('and')
    expect(page).to have_css('.search-ex', count: 3)
    expect(page).to have_css('.search-ex-move', count: 2)
  end

  it "searches for the problematicly named figure \"Rory O'More\" work" do
    rory = FactoryGirl.create(:dance_with_a_rory_o_more)
    tag_all_dances
    visit search_path
    select "Rory O'More"
    wait_to_load
    expect(page).to have_content(rory.title)
    expect(rory.title).to eq("Just Rory")
  end

  it "'not' filter works" do
    dance
    only_a_swing = FactoryGirl.create(:dance_with_a_swing)
    tag_all_dances
    visit search_path
    expect(page).to have_text(only_a_swing.title)
    expect(page).to have_text(dance.title)
    select('not')
    select('swing', match: :first) # swing is present in the same select menu twice
    expect(page).to_not have_text(only_a_swing.title)
    expect(page).to have_text(dance.title) # because it has a figure that's not a swing
  end

  it "'&' and 'progression' filters work" do
    dances
    visit search_path
    select('&')
    select('slide along set', match: :first)
    all('.search-ex-op').last.select('progression')
    expect(page).to have_text('The Rendevouz')
    expect(page).to_not have_text('Box the Gnat Contra')
    expect(page).to_not have_text('Call Me')
    expect(page).to have_text('The Rendevouz')
  end

  describe 'editing tree shape' do
    it 'the precondition of all these other tests is fulfilled' do
      setup_and_filter
      expect(page).to have_css('.search-ex', count: 2)
      expect(page).to have_css('.search-ex-move', count: 1)
      expect(page).to have_css("#search-ex-root .search-ex-op") # js wait for...
      expect(find("#search-ex-root .search-ex-op", match: :first).value).to eq('and')
      expect(find("#search-ex-root .search-ex .search-ex-op").value).to eq('figure')
      expect(find("#search-ex-root .search-ex .search-ex-move").value).to eq('*')
      expect(page).to have_content('Call Me')
      expect(page).to have_content('Box the Gnat Contra')
      expect(page).to have_content('The Rendevouz')
    end

    it "clicking 'add and' inserts a figure filter that responds to change events" do
      setup_and_filter
      add_search_ex find('#search-ex-root')
      expect(page).to have_css('.search-ex', count: 3)
      expect(page).to have_css('.search-ex-move', count: 2)
      all('.search-ex-move').first.select('chain')
      all('.search-ex-move').last.select('circle')
      expect(page).to have_content('Call Me')
      expect(page).to_not have_content('Box the Gnat Contra')
      expect(page).to_not have_content('The Rendevouz')
    end

    it "changing from 'and' to 'figure' purges subfilters and installs a new working move select" do
      setup_and_filter
      select('circle')        # rendevous and call me
      expect(page).to have_css('.search-ex', count: 2)
      expect(page).to have_css('.search-ex-move', count: 1)
      first('.search-ex-op').select('figure')
      select('chain')
      expect(page).to have_css('.search-ex', count: 1)
      expect(page).to have_css('.search-ex-move', count: 1)
      expect(page).to_not have_content('The Rendevouz')
      expect(page).to have_content('Box the Gnat Contra')
      expect(page).to have_content('Call Me')
    end

    it "change from an empty 'or' to 'no'" do
      setup_and_filter
      all('.search-ex-op').last.select('or');
      expect(page).to have_css('.search-ex-op', count: 4)
      expect(page).to have_css('.search-ex', count: 4)
      expect(page).to have_css('.search-ex-move', count: 2)
      delete_search_ex all('.search-ex').last
      expect(page).to have_css('.search-ex', count: 3) # css wait
      delete_search_ex all('.search-ex').last
      expect(page).to have_css('.search-ex', count: 2) # css wait
      all('.search-ex-op').last.select('no');
      expect(page).to have_css('.search-ex', count: 3) # <- the main point here
    end

    xdescribe 'figure query sentence' do
      # "figure: chain" => "dances with a chain"
      # "no (figure: chain)" => "dances with no chain"
      # "no ((figure: chain) or (figure: hey))" => "dances with no chain or hey"
      it 'works with precondition' do
        setup_and_filter
        expect(page).to have_content('dances with any figure')
      end
    end

    def visit_page_with_testing_query
      visit '/s'
      select 'and'
      find_all('.search-ex-op', count: 3).last.select('progression')
      # ['and', ['figure', '*'], ['progression']]
    end

    describe 'casts' do
      it "cast from 'and' to 'or'" do
        visit_page_with_testing_query
        first('.search-ex-op').select('or')
        expect(page).to have_css('#debug-lisp', text: '[ "or", [ "figure", "*" ], [ "progression" ] ]', visible: false)
      end

      it "cast to 'not'" do
        visit_page_with_testing_query
        first('.search-ex-op').select('not')
        expect(page).to have_css('#debug-lisp', text: '[ "not", [ "and", [ "figure", "*" ], [ "progression" ] ] ]', visible: false)
        expect(page).to have_css('.search-ex-op', count: 4)
      end
    end

    describe 'deletion' do
      it "works" do
        visit_page_with_testing_query
        all('.search-ex-menu-toggle', count: 3).last.click
        find('a.search-ex-delete').click
        expect(page).to have_css('#debug-lisp', text: '[ "and", [ "figure", "*" ] ]', visible: false)
      end

      it "menu item isn't visible for the root node" do
        visit_page_with_testing_query
        first('.search-ex-menu-toggle').click
        expect(page).to_not have_css('.search-ex-delete')
      end

      it "menu item isn't visible for a subexpression that's required" do
        visit_page_with_testing_query
        first('.search-ex-op').select('not')
        expect(page).to have_css('.search-ex-op', count: 4)
        expect(page).to have_css('#debug-lisp', text: '[ "not", [ "and", [ "figure", "*" ], [ "progression" ] ] ]', visible: false)
        all('.search-ex-menu-toggle', count: 4)[1].click
        expect(page).to have_css('.search-ex-menu-entries')
        expect(page).to_not have_css('.search-ex-delete')
      end
    end

    describe 'adding a subexpression' do
      let (:search_ex_add_subexpression_selector) { ".search-ex-add-subexpression" }
      it "add subexpression button works" do
        visit_page_with_testing_query
        all('.search-ex-menu-toggle', count: 3).first.click
        find(search_ex_add_subexpression_selector).click
        expect(page).to have_css('.search-ex-op', count: 4)
        expect(page).to have_css("#debug-lisp", text: '[ "and", [ "figure", "*" ], [ "progression" ], [ "figure", "*" ] ]', visible: false)
      end

      it "add subexpression button isn't available if it wouldn't be syntactically valid" do
        visit '/s'
        find('.search-ex-menu-toggle').click
        expect(page).to have_css('.search-ex-menu-entries')
        expect(page).to_not have_css(search_ex_add_subexpression_selector)
      end
    end


  end

  describe 'FigureSearchEx' do
    it "changing move changes search results" do
      setup_and_filter
      select('circle')
      expect(page).to have_content('The Rendevouz')
      expect(page).to_not have_content('Box the Gnat Contra')
      expect(page).to have_content('Call Me')
    end

    it "[...] is visible initially, when figure is 'any figure'" do
      visit search_path
      expect(page).to have_css('button.search-ex-toggle-parameters', count: 1)
    end

    it 'changing figure filter hides this [...] but creates two more [...]' do
      visit search_path
      select('then')
      expect(page).to have_css('button.search-ex-toggle-parameters', count: 2)
    end

    it "clicking [...] toggles parameter visiblity and button color" do
      visit search_path
      select('chain')
      expect(page).to_not have_css('.search-ex-figure-parameters')
      expect(page).to have_css('.search-ex-toggle-parameters.btn-default')
      expect(page).to_not have_css('.search-ex-toggle-parameters.btn-primary')
      toggle_figure_search_ex_paramters
      expect(page).to have_css('.search-ex-toggle-parameters.btn-primary')
      expect(page).to_not have_css('.search-ex-toggle-parameters.btn-default')
      expect(page).to have_css('.search-ex-figure-parameters')
      toggle_figure_search_ex_paramters
      expect(page).to_not have_css('.search-ex-ellipsis.ellipsis-expanded')
      expect(page).to_not have_css('.search-ex-figure-parameters')
    end

    context 'parameters' do
      it "circle 4 places finds only 'The Rendevouz'" do
        with_retries do
          dances
          visit search_path
          select('circle')
          toggle_figure_search_ex_paramters
          select('4 places')
          expect(page).to_not have_content('Box the Gnat Contra') # no circles
          expect(page).to_not have_content('Call Me') # has circle left 3 places
          expect(page).to have_content('The Rendevouz') # has circle left 3 & 4 places
          expect(page).to have_css("#debug-lisp", visible: false, text: '[ "figure", "circle", "*", "360", "*" ]')
        end
      end

      it "circle right finds only a dance with circle right" do
        visit search_path
        right = FactoryGirl.create(:dance_with_a_circle_right)
        dances
        select('circle')
        toggle_figure_search_ex_paramters
        choose('right')

        expect(page).to_not have_content('The Rendevouz') # has circle left 3 & 4 places
        expect(page).to_not have_content('Box the Gnat Contra') # no circles
        expect(page).to_not have_content('Call Me') # has circle left 3 places
        expect(page).to have_content(right.title) # has circle right
        expect(page).to have_css('#debug-lisp', visible: false, text: '[ "figure", "circle", false, "*", "*" ]')
      end

      it "If the [...] is clicked, it explicitly specifies parameters in the query" do
        dances
        visit search_path
        select('circle')

        expect(page).to have_content('The Rendevouz') # has circle left 3 & 4 places
        expect(page).to_not have_content('Box the Gnat Contra') # no circles
        expect(page).to have_content('Call Me') # has circle left 3 places
        expect(page).to have_css("#debug-lisp", visible: false, text: '[ "figure", "circle" ]') # first query

        toggle_figure_search_ex_paramters

        expect(page).to have_content('The Rendevouz') # has circle left 3 & 4 places
        expect(page).to_not have_content('Box the Gnat Contra') # no circles
        expect(page).to have_content('Call Me') # has circle left 3 places
        expect(page).to have_css("#debug-lisp", visible: false, text: '[ "figure", "circle", "*", "*", "*" ]') # second query
      end

      it 'circle has an angle select box with the right options' do
        visit search_path
        select('circle')
        toggle_figure_search_ex_paramters
        angles = JSLibFigure.angles_for_move('circle')
        too_small_angle = angles.min - 90
        too_big_angle = angles.max + 90
        expect(page).to_not have_css("#search-ex-root select option", text: JSLibFigure.degrees_to_words(too_small_angle, 'circle'))
        expect(page).to_not have_css("#search-ex-root select option", text: JSLibFigure.degrees_to_words(too_big_angle, 'circle'))
        angles.each do |angle|
          expect(page).to have_css("#search-ex-root select option[value='#{angle}']", text: JSLibFigure.degrees_to_words(angle, 'circle'))
        end
        expect(page).to have_css("#search-ex-root .search-ex-figure-parameters select option[value='*']", count: 2) # 2 = places + beats
      end

      it "swing for 8 doesn't find 'The Rendevouz', which features only long swings" do
        dances
        visit search_path
        select('swing', match: :first)
        toggle_figure_search_ex_paramters
        select('8', match: :prefer_exact) # '8' is in the menu twice, and also in 'figure 8'

        expect(page).to_not have_content('The Rendevouz') # has circle left 3 & 4 places
        expect(page).to have_content('Box the Gnat Contra') # no circles
        expect(page).to have_content('Call Me') # has circle left 3 places
        expect(page).to have_css("#debug-lisp", visible: false, text: '[ "figure", "swing", "*", "*", "8" ]')
      end

      it "non-balance & swing doesn't find 'The Rendevouz', which features only balance & swings" do
        dances
        visit search_path
        select('swing', match: :first)
        toggle_figure_search_ex_paramters
        select('none')

        expect(page).to_not have_content('The Rendevouz') # has circle left 3 & 4 places
        expect(page).to have_content('Box the Gnat Contra') # no circles
        expect(page).to have_content('Call Me') # has circle left 3 places
        expect(page).to have_css('#debug-lisp', visible: false, text: '[ "figure", "swing", "*", "none", "*" ]')
      end

      it 'labels appear on chooser elements' do
        visit search_path
        toggle_figure_search_ex_paramters
        select('swing', match: :first)             # swing uses simple label system
        expect(page).to have_css('.chooser-label-text', text: 'who')
        expect(page).to have_css('.chooser-label-text', text: 'prefix')
        expect(page).to have_css('.chooser-label-text', text: 'beats')
        select('allemande orbit')                  # allemande orbit uses fancier label system
        expect(page).to have_css('.chooser-label-text', text: 'who')
        expect(page).to have_css('.chooser-label-text', text: 'allemande')
        expect(page).to have_css('.chooser-label-text', text: 'inner')
        expect(page).to have_css('.chooser-label-text', text: 'outer')
        expect(page).to have_css('.chooser-label-text', text: 'beats')
      end

      it "allemande with ladles finds only 'Box the Gnat'" do
        dances
        visit search_path
        allemande = FactoryGirl.create(:dance_with_a_gentlespoons_allemande_left_once)

        select('allemande')
        toggle_figure_search_ex_paramters
        select('ladles')

        expect(page).to_not have_content('The Rendevouz')
        expect(page).to have_content('Box the Gnat Contra')
        expect(page).to_not have_content('Call Me')
        expect(page).to_not have_content(allemande.title)
        expect(page).to have_css('#debug-lisp', visible: false, text: '[ "figure", "allemande", "ladles", "*", "*", "*" ]')
      end

      it "allemande has the right dancer chooser menu entries" do
        dances
        visit search_path
        select('allemande')
        toggle_figure_search_ex_paramters

        expect(page).to have_css("option[value='ladles']")
        expect(page).to have_css("option[value='gentlespoons']")
        expect(page).to have_css("option[value='neighbors']")
        expect(page).to have_css("option[value='partners']")
        expect(page).to have_css("option[value='same roles']")
        expect(page).to have_css("option[value='shadows']")
        expect(page).to have_css("option[value='ones']")
        expect(page).to have_css("option[value='twos']")
        expect(page).to have_css("option[value='first corners']")
        expect(page).to have_css("option[value='second corners']")
        expect(page).to have_css("option[value='shadows']")
        # unsure why failing - door is locked, move on to the next
        expect(page).to_not have_css("option[value='prev neighbors']")
        expect(page).to_not have_css("option[value='next neighbors']")
        expect(page).to_not have_css("option[value='2nd neighbors']")
        expect(page).to_not have_css("option[value='3rd neighbors']")
        expect(page).to_not have_css("option[value='4th neighbors']")
        expect(page).to_not have_css("option[value='1st shadows']")
        expect(page).to_not have_css("option[value='2nd shadows']")
      end

      it "allemande with allemande left finds only 'Just Allemande'" do
        allemande = FactoryGirl.create(:dance_with_a_gentlespoons_allemande_left_once)
        dances
        visit search_path

        select('allemande')
        toggle_figure_search_ex_paramters
        choose('left', exact: true)

        expect(page).to_not have_content('The Rendevouz')
        expect(page).to_not have_content('Box the Gnat Contra')
        expect(page).to_not have_content('Call Me')
        expect(page).to have_content(allemande.title)
        expect(page).to have_css('#debug-lisp', visible: false, text: '[ "figure", "allemande", "*", false, "*", "*" ]')
      end


      it "allemande once around works" do
        allemande = FactoryGirl.create(:dance_with_a_gentlespoons_allemande_left_once)
        dances
        visit search_path

        select('allemande')
        toggle_figure_search_ex_paramters
        select('once')

        expect(page).to_not have_content('The Rendevouz')
        expect(page).to_not have_content('Box the Gnat Contra')
        expect(page).to_not have_content('Call Me')
        expect(page).to have_content(allemande.title)
        expect(page).to have_css('#debug-lisp', visible: false, text: '[ "figure", "allemande", "*", "*", "360", "*" ]')
      end


      it "text input keywords work" do
        apple = FactoryGirl.create(:dance_with_a_custom, custom_text: 'apple', title: 'just apple')
        banana = FactoryGirl.create(:dance_with_a_custom, custom_text: 'banana', title: 'just banana')
        orange = FactoryGirl.create(:dance_with_a_custom, custom_text: 'orange', title: 'just orange')
        apple_banana = FactoryGirl.create(:dance_with_a_custom, custom_text: 'apple banana', title: 'apple_banana')

        dances
        visit search_path
        select('custom')
        toggle_figure_search_ex_paramters
        find(".search-ex-figure-parameters input[type=text]").set('apple orange')
        dances.each do |dance|
          expect(page).to_not have_content(dance.title)
        end
        expect(page).to have_content(apple.title)
        expect(page).to_not have_content(banana.title)
        expect(page).to have_content(orange.title)
        expect(page).to have_content(apple_banana.title)
        expect(page).to have_css('#debug-lisp', visible: false, text: '[ "figure", "custom", "apple orange", "*" ]')
      end

      it "wrist grip filter works" do
        dances
        visit search_path
        grip = FactoryGirl.create(:dance_with_a_wrist_grip_star)

        select('star')
        toggle_figure_search_ex_paramters
        select('unspecified')

        expect(page).to_not have_content('The Rendevouz')
        expect(page).to_not have_content('Box the Gnat Contra')
        expect(page).to have_content('Call Me')
        expect(page).to_not have_content(grip.title)

        expect(page).to have_css('#debug-lisp', visible: false, text: '[ "figure", "star", "*", "*", "", "*" ]')
      end

      it "facing filter works" do
        fb = FactoryGirl.create(:dance_with_a_down_the_hall, march_facing: 'forward then backward')
        f = FactoryGirl.create(:dance_with_a_down_the_hall, march_facing: 'forward')
        b = FactoryGirl.create(:dance_with_a_down_the_hall, march_facing: 'backward')
        tag_all_dances
        visit search_path

        select('down the hall')
        toggle_figure_search_ex_paramters
        select('forward then backward')

        expect(page).to_not have_content(f.title)
        expect(page).to_not have_content(b.title)
        expect(page).to have_content(fb.title)
      end

      it "down the hall ender filter works" do
        ta = FactoryGirl.create(:dance_with_a_down_the_hall, down_the_hall_ender: 'turn-alone', title: 'dth_alone')
        tc = FactoryGirl.create(:dance_with_a_down_the_hall, down_the_hall_ender: 'turn-couple', title: 'dth_couples')
        circle = FactoryGirl.create(:dance_with_a_down_the_hall, down_the_hall_ender: 'circle', title: 'dth_circle')
        unspec = FactoryGirl.create(:dance_with_a_down_the_hall, down_the_hall_ender: '', title: 'dth_unspec')
        tag_all_dances
        visit search_path

        select('down the hall')
        toggle_figure_search_ex_paramters
        select('turn as a couple')
        # select('turn alone') # hard because multiple
        select('bend into a ring')
        expect(page).to_not have_content(tc.title)
        expect(page).to_not have_content(unspec.title)
        expect(page).to_not have_content(ta.title)
        expect(page).to have_content(circle.title)
      end

      it "half_or_full filter works" do
        poussette = FactoryGirl.create(:dance_with_a_full_poussette)
        dances
        visit search_path

        select('poussette')
        toggle_figure_search_ex_paramters
        choose('full')

        dances.each do |dance|
          expect(page).to_not have_content(dance.title)
        end
        expect(page).to have_content(poussette.title)
        expect(page).to have_css('#debug-lisp', visible: false, text: '[ "figure", "poussette", 1, "*", "*", "*", "*" ]')
      end

      it "hey_length filter works" do
        hey_dances = %w(ladles%%1 half ladles%%2 full).map {|hey_length| FactoryGirl.create(:dance_with_a_hey, hey_length: hey_length)}
        hey_lengths = ['less than half',
                       'half',
                       'between half and full',
                       'full']
        tag_all_dances
        visit search_path

        select('hey')
        toggle_figure_search_ex_paramters
        hey_dances.each_with_index do |dance, i|
          hey_length = hey_lengths[i]
          select(hey_length)

          hey_dances.each do |dance2|
            if dance == dance2
              expect(page).to have_content(dance2.title)
            else
              expect(page).to_not have_content(dance2.title)
            end
          end
          expect(page).to have_css("#debug-lisp", visible: false, text: %Q([ "figure", "hey", "*", "*", "*", #{hey_length.inspect}, "*", "*", "*", "*", "*", "*" ]))
        end
      end

      it 'aliases are subsets' do
        do_si_do = FactoryGirl.create(:dance_with_a_do_si_do)
        see_saw = FactoryGirl.create(:dance_with_a_see_saw)
        tag_all_dances
        visit search_path
        select('see saw')
        expect(page).to have_content(see_saw.title)
        expect(page).to_not have_content(do_si_do.title)
        toggle_figure_search_ex_paramters
        choose('*')
        expect(page).to have_content(do_si_do.title)
        expect(page).to have_content(see_saw.title)
        # expect(page).to have_content("Showing dances with a * do si do *")
        expect(find(".search-ex-move").value).to eq('do si do')
        choose('left')
        expect(page).to have_content(see_saw.title)
        expect(page).to_not have_content(do_si_do.title)
        expect(find(".search-ex-move").value).to eq('do si do')
        # expect(page).to have_content("Showing dances with a * see saw *")
      end
    end
  end

  describe 'dialect' do
    it 'figure filter move' do
      expect_any_instance_of(WelcomeController).to receive(:dialect).and_return(JSLibFigure.test_dialect)
      with_retries do
        visit search_path
        dances

        expect(page).to_not have_css('option',                  text: exactly('allemande'))
        expect(page).to     have_css('option[value=allemande]', text: exactly('almond'))

        expect(page).to_not have_css('option',             text: exactly('gyre'))
        expect(page).to     have_css('option[value=gyre]', text: exactly('darcy'))

        select('almond')

        expect(page).to have_content('Box the Gnat Contra')
        expect(page).to_not have_content('The Rendevouz')
        expect(page).to_not have_content('Call Me')
      end
    end

    it 'figure filter dancers' do
      expect_any_instance_of(WelcomeController).to receive(:dialect).and_return(JSLibFigure.test_dialect)
      with_retries do
        allemande = FactoryGirl.create(:dance_with_a_gentlespoons_allemande_left_once)
        dances
        visit search_path

        select('almond')
        toggle_figure_search_ex_paramters
        select('ravens')

        expect(page).to_not have_content('The Rendevouz')
        expect(page).to have_content('Box the Gnat Contra')
        expect(page).to_not have_content('Call Me')
        expect(page).to_not have_content(allemande.title)
        expect(page).to have_css('#debug-lisp', visible: false, text: '[ "figure", "allemande", "ladles", "*", "*", "*" ]')
      end
    end
  end

  xdescribe 'back button' do
    # these tests are xited because they found a real bug on chrome
    # that I can't fix right now. https://github.com/contradb/contra/issues/611
    it 'works' do
      dances
      visit search_path
      select('and')
      expect(page).to have_css('.search-ex-move', count: 2) # js wait
      all('.search-ex-move').first.select('swing', match: :first)
      all('.search-ex-move').last.select('allemande')
      all('.search-ex-ellipsis').last.click
      select('ladles')        # ladles allemande right 1½ for '*' beats
      choose('right')
      select('1½')
      click_button('add and')
      expect(page).to have_css('.search-ex-op', count: 4) # js wait
      all('.search-ex-op').last.select('formation')
      select('improper')
      click_link('Box the Gnat Contra')
      expect(page).to have_content('partners swing') # wait for page to load
      page.go_back
      move_selector = '.search-ex-move'
      expect(page).to have_css(move_selector, count: 2)
      expect(all(move_selector).first.value).to eq('swing')
      expect(all(move_selector).last.value).to eq('allemande')
      expect(page).to_not have_content('Processing...')
      expect(page).to have_css('.search-ex-ellipsis.ellipsis-expanded', count: 1)
      expect(page).to have_css('.search-ex-accordion', count: 1, visible: true)
      expect(page).to have_css('.chooser-argument', count: 4)
      expect(all(".chooser-argument")[0].value).to eq('ladles')
      expect(find(".chooser-argument [type=radio][value='*']")).to_not be_checked
      expect(find(".chooser-argument [type=radio][value='true']")).to be_checked
      expect(find(".chooser-argument [type=radio][value='false']")).to_not be_checked
      expect(all(".chooser-argument")[2].value.to_s).to eq(540.to_s)
      expect(all(".chooser-argument")[3].value).to eq('*')
      expect(page).to have_css('.search-ex-formation', count: 1)
      op_values = find_all('.search-ex-op').map(&:value)
      expect(op_values.count('and')).to eq(1)
      expect(op_values.count('figure')).to eq(2)
      expect(op_values.count('formation')).to eq(1)
      expect(page).to have_content('Box the Gnat Contra')
      expect(page).to_not have_content('The Rendevouz')
      expect(page).to_not have_content('Call Me')
      expect(page).to have_content('Showing dances with a swing and a ladles allemande right 1½ and an improper formation.')
    end

    it 'all filters at least load when back-ed' do
      dances
      visit search_path
      filters = page.find('.search-ex-op').all('option').map {|elt| elt['innerHTML'].gsub('&amp;', '&') }
      filters.each do |filter|
        page.select(filter, match: :first)
        expect(page).to have_text(/Showing \d+ to \d+ of \d+ entries/)
        page.refresh
        # when filters are broken on reload, it has an empty table and doesn't show this text:
        expect(page).to have_text(/Showing \d+ to \d+ of \d+ entries/)
      end
    end

    it 'decorates subfilters with [x] buttons, conjunctions, and "add or"' do
      dances
      visit search_path
      select('or')
      click_link(dances.first.title)
      expect(page).to have_css('h1', text: dances.first.title)
      page.go_back
      expect(page).to have_css('.search-ex[data-op=or]', count: 2)
      expect(page).to have_css('.search-ex-remove', count: 2)
      expect(page).to have_css('button.search-ex-add', text: 'add or')
      click_button('add or')
      expect(page).to have_css('.search-ex-remove', count: 3)
      all('.search-ex-remove').last.click
      expect(page).to have_css('.search-ex-remove', count: 2)
    end
  end

  private
  def exactly(string)
    /\A#{string}\z/
  end

  def tag_all_dances(tag: FactoryGirl.create(:tag, :verified), user: FactoryGirl.create(:user))
    Dance.all.each do |dance|
      FactoryGirl.create(:dut, dance: dance, tag: tag, user: user) unless Dut.find_by(dance_id: dance.id, tag_id: tag.id, user_id: user.id)
    end
  end

  def wait_to_load
    expect(page).to_not have_css('.floating-loading-indicator')
  end

  def setup_and_filter
    dances
    visit search_path
    # get down to (and (filter '*')):
    select('and')
    delete_search_ex all('.search-ex', count: 3).last
  end

  def delete_search_ex(capy_search_ex_node)
    capy_search_ex_node.find('.search-ex-menu-toggle', match: :first).click
    capy_search_ex_node.find('.search-ex-delete').click
  end

  def add_search_ex(capy_search_ex_node)
    capy_search_ex_node.find('.search-ex-menu-toggle', match: :first).click
    capy_search_ex_node.find('.search-ex-add-subexpression').click
  end

  def toggle_figure_search_ex_paramters(capy_search_ex_node = find("#search-ex-root"))
    capy_search_ex_node.find('button.search-ex-toggle-parameters').click
  end


end
