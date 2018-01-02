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
    let (:dance) {FactoryGirl.create(:box_the_gnat_contra, created_at: DateTime.now - 10.years)}
    it 'displays dance columns' do
      dance
      visit '/'
      expect(page).to have_link(dance.title, href: dance_path(dance))
      expect(page).to have_link(dance.choreographer.name, href: choreographer_path(dance.choreographer))
      expect(page).to have_text(dance.start_type)
      expect(page).to have_text(dance.hook)
      expect(page).to have_link(dance.user.name, href: user_path(dance.user))
      expect(page).to have_text(dance.updated_at.strftime('%Y-%m-%d'))
      expect(page).to_not have_text(dance.created_at.strftime('%Y-%m-%d')) # column invisible by default, it's not hidden, it's simply not there
      expect(page).to_not have_css('td', text: 'Published') # column invisible by default, it's not hidden, it's simply not there
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

    it "'anything but' works" do
      dance
      only_a_swing = FactoryGirl.create(:dance_with_a_swing)
      visit '/'
      expect(page).to have_text(only_a_swing.title)
      expect(page).to have_text(dance.title)
      select('anything but')
      select('swing', match: :first)
      expect(page).to_not have_text(only_a_swing.title)
      expect(page).to have_text(dance.title) # because it has a figure that's not a swing
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

      it "clicking '...' toggles 'ellipsis-expanded' class" do
        select('chain')
        expect(page).to_not have_css('.figure-filter-ellipsis.ellipsis-expanded')
        click_button '...'
        expect(page).to have_css('.figure-filter-ellipsis.ellipsis-expanded')
        click_button '...'
        expect(page).to_not have_css('.figure-filter-ellipsis.ellipsis-expanded')
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

          expect(page).to have_content('The Rendevouz') # has circle left 3 & 4 places
          expect(page).to_not have_content('Box the Gnat Contra') # no circles
          expect(page).to_not have_content('Call Me') # has circle left 3 places
          expect(find("#figure-query-buffer", visible: false).value).to eq('["figure","circle","*","360","*"]')
        end

        it "circle right finds only a dance with circle right" do
          right = FactoryGirl.create(:dance_with_a_circle_right)
          dances
          select('circle')
          click_button('...')
          choose('right')

          expect(page).to_not have_content('The Rendevouz') # has circle left 3 & 4 places
          expect(page).to_not have_content('Box the Gnat Contra') # no circles
          expect(page).to_not have_content('Call Me') # has circle left 3 places
          expect(page).to have_content(right.title) # has circle right
          expect(find("#figure-query-buffer", visible: false).value).to eq('["figure","circle","false","*","*"]')
        end

        it "A slightly different query is sent if the ... is clicked" do
          dances
          select('circle')

          expect(page).to have_content('The Rendevouz') # has circle left 3 & 4 places
          expect(page).to_not have_content('Box the Gnat Contra') # no circles
          expect(page).to have_content('Call Me') # has circle left 3 places
          expect(find("#figure-query-buffer", visible: false).value).to eq('["figure","circle"]') # first query

          click_button('...')

          expect(page).to have_content('The Rendevouz') # has circle left 3 & 4 places
          expect(page).to_not have_content('Box the Gnat Contra') # no circles
          expect(page).to have_content('Call Me') # has circle left 3 places
          expect(find("#figure-query-buffer", visible: false).value).to eq('["figure","circle","*","*","*"]') # second query
        end

        it 'circle has an angle select box with the right options' do
          select('circle')
          click_button('...')
          angles = JSLibFigure.angles_for_move('circle')
          too_small_angle = angles.min - 90
          too_big_angle = angles.max + 90
          expect(page).to_not have_css("#figure-filter-root select option", text: JSLibFigure.degrees_to_words(too_small_angle, 'circle'))
          expect(page).to_not have_css("#figure-filter-root select option", text: JSLibFigure.degrees_to_words(too_big_angle, 'circle'))
          angles.each do |angle|
            expect(page).to have_css("#figure-filter-root select option[value='#{angle}']", text: JSLibFigure.degrees_to_words(angle, 'circle'))
          end
          expect(page).to have_css("#figure-filter-root .figure-filter-accordion select option[value='*']")
        end

        it "swing for 8 doesn't find 'The Rendevouz', which features only long swings" do
          dances
          select('swing', match: :first)
          click_button('...')
          select('8', match: :prefer_exact) # '8' is in the menu twice, and also in 'figure 8'

          expect(page).to_not have_content('The Rendevouz') # has circle left 3 & 4 places
          expect(page).to have_content('Box the Gnat Contra') # no circles
          expect(page).to have_content('Call Me') # has circle left 3 places
          expect(find("#figure-query-buffer", visible: false).value).to eq('["figure","swing","*","*","8"]')
        end

        it "non-balance & swing doesn't find 'The Rendevouz', which features only balance & swings" do
          dances
          select('swing', match: :first)
          click_button('...')
          choose('no')

          expect(page).to_not have_content('The Rendevouz') # has circle left 3 & 4 places
          expect(page).to have_content('Box the Gnat Contra') # no circles
          expect(page).to have_content('Call Me') # has circle left 3 places
          expect(find("#figure-query-buffer", visible: false).value).to eq('["figure","swing","*","false","*"]')
        end

        it 'labels appear on chooser elements' do
          click_button('...')
          select('swing', match: :first)             # swing uses simple label system
          expect(page).to have_content('bal')
          expect(page).to have_content('who')
          expect(page).to have_content('beats')
          select('allemande orbit')                  # allemande orbit uses fancier label system
          expect(page).to have_content('who')
          expect(page).to have_content('allemande')
          expect(page).to have_content('inner')
          expect(page).to have_content('outer')
          expect(page).to have_content('for')
        end

        it "allemande with ladles finds only 'Box the Gnat'" do
          dances
          allemande = FactoryGirl.create(:dance_with_a_gentlespoons_allemande_left_once)

          select('allemande')
          click_button('...')
          select('ladles')

          expect(page).to_not have_content('The Rendevouz')
          expect(page).to have_content('Box the Gnat Contra')
          expect(page).to_not have_content('Call Me')
          expect(page).to_not have_content(allemande.title)
          expect(find("#figure-query-buffer", visible: false).value).to eq('["figure","allemande","ladles","*","*","*"]')
        end

        it "allemande with allemande left finds only 'Just Allemande'" do
          dances
          allemande = FactoryGirl.create(:dance_with_a_gentlespoons_allemande_left_once)

          select('allemande')
          click_button('...')
          choose('left', exact: true)
 
          expect(page).to_not have_content('The Rendevouz')
          expect(page).to_not have_content('Box the Gnat Contra')
          expect(page).to_not have_content('Call Me')
          expect(page).to have_content(allemande.title)
          expect(find("#figure-query-buffer", visible: false).value).to eq('["figure","allemande","*","false","*","*"]')
        end

        it "allemande once around works" do
          dances
          allemande = FactoryGirl.create(:dance_with_a_gentlespoons_allemande_left_once)

          select('allemande')
          click_button('...')
          select('once')
 
          expect(page).to_not have_content('The Rendevouz')
          expect(page).to_not have_content('Box the Gnat Contra')
          expect(page).to_not have_content('Call Me')
          expect(page).to have_content(allemande.title)
          expect(find("#figure-query-buffer", visible: false).value).to eq('["figure","allemande","*","*","360","*"]')
        end


        it "text input keywords work" do
          dances
          apple = FactoryGirl.create(:dance_with_a_custom, custom_text: 'apple', title: 'just apple')
          banana = FactoryGirl.create(:dance_with_a_custom, custom_text: 'banana', title: 'just banana')
          orange = FactoryGirl.create(:dance_with_a_custom, custom_text: 'orange', title: 'just orange')
          apple_banana = FactoryGirl.create(:dance_with_a_custom, custom_text: 'apple banana', title: 'apple_banana')

          select('custom')
          click_button('...')
          find(:css, "input.chooser-argument[type=string]").set('apple orange')
 
          dances.each do |dance|
            expect(page).to_not have_content(dance.title)
          end
          expect(page).to have_content(apple.title)
          expect(page).to_not have_content(banana.title)
          expect(page).to have_content(orange.title)
          expect(page).to have_content(apple_banana.title)
          expect(find("#figure-query-buffer", visible: false).value).to eq('["figure","custom","apple orange","*"]')
        end

        it "wrist grip filter works" do
          dances
          grip = FactoryGirl.create(:dance_with_a_wrist_grip_star)

          select('star')
          click_button('...')
          select('unspecified')
 
          expect(page).to_not have_content('The Rendevouz')
          expect(page).to_not have_content('Box the Gnat Contra')
          expect(page).to have_content('Call Me')
          expect(page).to_not have_content(grip.title)

          expect(find("#figure-query-buffer", visible: false).value).to eq('["figure","star","*","*","","*"]')
        end

        it "facing filter works" do
          fb = FactoryGirl.create(:dance_with_a_down_the_hall, march_facing: 'forward then backward')
          f = FactoryGirl.create(:dance_with_a_down_the_hall, march_facing: 'forward')
          b = FactoryGirl.create(:dance_with_a_down_the_hall, march_facing: 'backward')

          select('down the hall')
          click_button('...')
          select('forward then backward')
 
          expect(page).to_not have_content(f.title)
          expect(page).to_not have_content(b.title)
          expect(page).to have_content(fb.title)
        end

        it "down the hall ender filter works" do
          ta = FactoryGirl.create(:dance_with_a_down_the_hall, down_the_hall_ender: 'turn-alone', title: 'dth_alone')
          tc = FactoryGirl.create(:dance_with_a_down_the_hall, down_the_hall_ender: 'turn-couples', title: 'dth_couples')
          circle = FactoryGirl.create(:dance_with_a_down_the_hall, down_the_hall_ender: 'circle', title: 'dth_circle')
          unspec = FactoryGirl.create(:dance_with_a_down_the_hall, down_the_hall_ender: '', title: 'dth_unspec')

          select('down the hall')
          click_button('...')
          select('turn as couples')
          # select('turn alone') # hard because multiple
          select('bend into a ring')
 
          expect(page).to_not have_content(ta.title)
          expect(page).to_not have_content(tc.title)
          expect(page).to_not have_content(unspec.title)
          expect(page).to have_content(circle.title)
        end

        it "half_or_full filter works" do
          hey = FactoryGirl.create(:dance_with_a_full_hey)
          dances

          select('hey',  match: :prefer_exact)
          click_button('...')
          choose('full')
 
          dances.each do |dance|
            expect(page).to_not have_content(dance.title)
          end
          expect(page).to have_content(hey.title)
          expect(find("#figure-query-buffer", visible: false).value).to eq('["figure","hey","*","1","*","*"]')
        end
      end
    end

    describe 'back button' do
      it 'works' do
        dances
        visit '/'
        select('and')
        expect(page).to have_css('.figure-filter-move', count: 2) # wait for js to run
        all('.figure-filter-move').first.select('swing', match: :first)
        all('.figure-filter-move').last.select('allemande')
        all('.figure-filter-ellipsis').last.click
        select('ladles')        # ladles allemande right 1½ for '*' beats
        choose('right')
        select('1½')
        click_link('Box the Gnat Contra')
        expect(page).to have_content('partners swing') # wait for page to load
        page.go_back
        move_selector = '.figure-filter-move'
        expect(page).to have_css(move_selector, count: 2)
        expect(all(move_selector).first.value).to eq('swing')
        expect(all(move_selector).last.value).to eq('allemande')
        expect(page).to have_css('.figure-filter-ellipsis.ellipsis-expanded', count: 1)
        expect(page).to have_css('.figure-filter-accordion', count: 1, visible: true)
        expect(page).to have_css('.chooser-argument', count: 4)
        expect(all(".chooser-argument")[0].value).to eq('ladles')
        expect(find(".chooser-argument [type=radio][value='*']")).to_not be_checked
        expect(find(".chooser-argument [type=radio][value='true']")).to be_checked
        expect(find(".chooser-argument [type=radio][value='false']")).to_not be_checked
        expect(all(".chooser-argument")[2].value.to_s).to eq(540.to_s)
        expect(all(".chooser-argument")[3].value).to eq('*')
        expect(page).to have_content('Box the Gnat Contra')
        expect(page).to_not have_content('The Rendevouz')
        expect(page).to_not have_content('Call Me')
        expect(page).to have_content('Showing dances with a swing and a ladles allemande right 1½ for *.')
      end
    end

    describe 'columns' do
      it "Clicking vis toggles buttons cause columns to disappear" do
        dances
        visit '/'
        %w[Title Choreographer Formation Hook User Updated].each do |col|
          expect(page).to have_css('#dances-table th', text: col)
          expect(page).to have_css('button.toggle-vis-active', text: col)
          expect(page).to_not have_css('button.toggle-vis-inactive', text: col)
          click_button col
          expect(page).to_not have_css('#dances-table th', text: col)
          expect(page).to have_css('button.toggle-vis-inactive', text: col)
          expect(page).to_not have_css('button.toggle-vis-active', text: col)
          click_button col
          expect(page).to have_css('#dances-table th', text: col)
          expect(page).to have_css('button.toggle-vis-active', text: col)
          expect(page).to_not have_css('button.toggle-vis-inactive', text: col)
        end
        %w[Entered Published].each do |col|
          expect(page).to_not have_css('#dances-table th', text: col)
          expect(page).to_not have_css('button.toggle-vis-active', text: col)
          expect(page).to  have_css('button.toggle-vis-inactive', text: col)
          click_button col
          expect(page).to have_css('#dances-table th', text: col)
          expect(page).to_not have_css('button.toggle-vis-inactive', text: col)
          expect(page).to have_css('button.toggle-vis-active', text: col)
          click_button col
          expect(page).to_not have_css('#dances-table th', text: col)
          expect(page).to have_css('button.toggle-vis-inactive', text: col)
          expect(page).to_not have_css('button.toggle-vis-active', text: col)
        end
      end
    end
  end
end
