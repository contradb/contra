# coding: utf-8
require 'rails_helper'
require 'support/scrutinize_layout'

describe 'Creating dances', js: true do
  it 'creates a new dance with non-javascript data' do
    with_login do
      visit '/dances/new'
      expect(page).to have_current_path(new_dance_path)
      fill_in 'dance_title', with: 'Call Me'
      fill_in 'dance[choreographer_name]', with: 'Cary Ravitz'
      fill_in 'dance[start_type]', with: 'improper'
      fill_in 'dance[preamble]', with: 'long wavy lines gents out'
      fill_in 'dance[hook]', with: 'spin to your partner'
      choose 'Private'
      click_button 'Save Dance'

      expect(page).to have_css('h1', text: 'Call Me')
      expect(page).to have_content('Cary Ravitz')
      expect(page).to have_content('improper')
      expect(page).to have_content('long wavy lines gents out') # preamble
      expect(page).to have_content('spin to your partner') # hook
      expect(page).to have_content('Private')
      expect(page).to_not have_content('Published')
    end
  end

  pending 'tests choreographer auto-complete'

  it 'records figures' do
    with_login do
      visit '/dances/new'
      fill_in 'dance_title', with: 'Rover McGrover'
      fill_in 'dance[choreographer_name]', with: 'Cary Ravitz'
      fill_in 'dance[start_type]', with: 'improper'

      expect(page).to have_css('#figure-0')
      find('#figure-0').click
      7.times { click_button 'Remove' }

      select('box the gnat')
      select('partners')
      check('bal')
      # 'right' hand is default
      #  8 beats is default
      fill_in('note', with: 'hastily')
      expect(page).to have_content('partners balance & box the gnat hastily')
      click_on 'Save Dance'

      dance = Dance.last

      expect(dance.title).to eql('Rover McGrover')
      expect(current_path).to eq dance_path(dance.id)
      expect(page).to have_content('Dance was successfully created')
      expect(page).to have_content('partners balance & box the gnat hastily')
    end
  end

  context 'figure menu' do
    context 'progressions' do
      it "'add' works and present iff not progression" do
        with_login do
          visit '/dances/new'
          find('#figure-menu-3').click
          click_on('Add ⁋rogression')
          expect(page).to have_css('#figure-3', text: 'stand still ⁋')
          expect(page).to have_css('#figure-7', text: 'stand still ⁋')
          expect(page).to have_text('⁋', count: 2)
          find('#figure-menu-3').click
          expect(page).to_not have_content('Add ⁋rogression')
        end
      end

      it "'remove' works and present iff progression" do
        with_login do
          visit '/dances/new'
          find('#figure-menu-3').click
          expect(page).to have_content('Add ⁋rogression') # js wait
          expect(page).to_not have_content('Remove ⁋rogression')
          page.find('body').send_keys(:escape)                  # wave off menu
          expect(page).to_not have_content('Remove ⁋rogression') # js wait
          find('#figure-menu-7').click
          click_on('Remove ⁋rogression')
          expect(page).to_not have_content('⁋')
        end
      end


    end
    it 'duplicate' do
      with_login do
        visit '/dances/new'
        find("#figure-3").click
        find("#move-3").select 'circle'
        select "5 places"
        find('#figure-menu-3').click
        click_on 'Duplicate'
        expect(page).to have_css('#figure-3', text: 'circle left 5 places')
        expect(page).to have_css('#figure-4', text: 'circle left 5 places')
      end
    end

    it 'delete figure' do
      with_login do
        visit '/dances/new'
        make_eight_circle_figures
        find('#figure-menu-4').click # 'circle to the left 5 places'
        click_on 'Delete Figure'
        expect(page).to have_text "circle left 1 place"
        expect(page).to have_text "circle left 2 places"
        expect(page).to have_text "circle left 3 places"
        expect(page).to have_text "circle left 4 places"
        expect(page).to_not have_text "circle left 5 places"
        expect(page).to have_text "circle left 6 places"
        expect(page).to have_text "circle left 7 places"
        expect(page).to have_text "circle left 8 places"
      end
    end

    it 'up' do
      with_login do
        visit '/dances/new'
        make_eight_circle_figures
        find('#figure-menu-4').click # 'circle to the left 5 places'
        click_on 'Up 2'
        expect(page).to have_words ["A1",
                                    "8 circle left 1 place",
                                    "8 circle left 2 places",
                                    "A2",
                                    "8 circle left 5 places",
                                    "8 circle left 3 places",
                                    "B1",
                                    "8 circle left 4 places",
                                    "8 circle left 6 places",
                                    "B2",
                                    "8 circle left 7 places",
                                    "8 circle left 8 places",
                                   ].join(' ')
      end
    end


    def make_eight_circle_figures
      8.times do |index|
        find("#figure-#{index}").click
        find("#move-#{index}").select 'circle'
        places = 'place'.pluralize(index+1)
        select "#{index+1} #{places}"
      end
    end
  end

  context 'add figure button' do
    it 'adds a figure after the selection, and selects it' do
      with_login do
        visit '/dances/new'
        expect(page).to have_content('stand still', count: 8)
        find('#figure-0').click
        select('chain')
        click_button('Add')
        expect(page).to have_words("A1 8 ladles chain 8 stand still move beats note")
        click_button('Add')
        expect(page).to have_words("A1 8 ladles chain 8 stand still A2 8 stand still move beats note")
      end
    end

    it 'adds a figure to the beginning and selects it if there is no selection' do
      with_login do
        visit '/dances/new'
        find('#figure-0').click
        select('chain')
        click_link('ladles chain')
        click_button('Add')
        expect(page).to have_words("A1 8 stand still move beats note 8 ladles chain")
      end
    end
  end

  context 'remove figure button' do
    it 'is greyed out when there is no selection' do
      with_login do
        visit '/dances/new'
        expect(page).to have_css('.delete-figure[disabled=disabled]')
        find('#figure-1').click
        expect(page).to_not have_css('.delete-figure[disabled=disabled]')
        find('#figure-1').click
        expect(page).to have_css('.delete-figure[disabled=disabled]')
      end
    end

    it 'removes the selection and selects the next-down figure' do
      with_login do
        visit '/dances/new'
        expect(page).to have_css('#figure-1')
        find('#figure-1').click
        select('do si do')
        find('#figure-0').click
        select('chain')
        expect(page).to have_words('A1 8 ladles chain')
        click_button('Remove')
        expect(page).to_not have_content('ladies chain')
        expect(page).to have_words('A1 8 ____ do si do once move who')
      end
    end

    it 'removes the selection and selects the next-up figure if there is no next down figure' do
      with_login do
        visit '/dances/new'
        expect(page).to have_css('#figure-7')
        find('#figure-7').click
        select('do si do')
        expect(page).to have_words('B2 8 stand still 8 ____ do si do')
        click_button('Remove')
        expect(page).to_not have_words('do si do')
        expect(page).to have_words('B2 8 stand still move')
      end
    end

    it 'removes the selection and selects nothing if there are no figures left' do
      with_login do
        visit '/dances/new'
        expect(page).to have_css('#figure-7')
        find('#figure-7').click
        8.times do
          expect(page).to_not have_css('.delete-figure[disabled=disabled]')
          expect(page).to have_css('label', text: 'move') # something is selected
          click_button('Remove')
        end
        expect(page).to have_css('.delete-figure[disabled=disabled]')
        expect(page).to_not have_css('label', text: 'move') # something isn't selected
      end
    end
  end

  context 'rotate figures button' do
    it 'works' do
      with_login do
        visit '/dances/new'
        expect(page).to have_css('#figure-0')

        # delete down to 3 figures
        find('#figure-0').click
        5.times do
          click_button('Remove')
        end
        find('#figure-0').click

        expect(page).to have_words('A1 8 stand still 8 stand still A2 8 stand still ⁋ Notes')
        click_button('Rotate')
        expect(page).to have_words('A1 8 stand still ⁋ 8 stand still A2 8 stand still Notes')
        click_button('Rotate')
        expect(page).to have_words('A1 8 stand still 8 stand still ⁋ A2 8 stand still Notes')
        click_button('Rotate')
        expect(page).to have_words('A1 8 stand still 8 stand still A2 8 stand still ⁋ Notes')
      end
    end
  end

  it 'UI interaction on some figures saves to the database' do
    with_login do
      visit '/dances/new'
      click_on 'figure-0'
      6.times { click_button('Remove') }
      select 'swing', match: :first
      select 'neighbors'
      choose 'balance'
      fill_in 'note', with: 'with gusto!'
      click_on 'figure-1'
      select 'allemande'
      select 'partners'
      choose 'left'
      select '1½'
      select '12'
      fill_in 'dance[choreographer_name]', with: 'Cary Ravitz'
      fill_in 'dance[start_type]', with: 'improper'
      click_button 'Save Dance'
      expect(page).to have_content('Dance was successfully created.')
      dance = Dance.last
      expect(dance.figures).to eq([{'move' => 'swing', 'parameter_values' => ['neighbors', 'balance', 16], 'note' => 'with gusto!'},
                                   {'move' => 'allemande', 'parameter_values' => ['partners', false, 540, 12], 'progression' => 1}])
    end
  end

  it 'users type text in their dialect and the db saves in using the default terms' do
    with_login do |user|
      allow_any_instance_of(User).to receive(:dialect).and_return(JSLibFigure.test_dialect)
      text_in_dialect = 'darcy ravens'
      text_in_canon = 'gyre ladles'
      visit new_dance_path
      click_on('stand still', match: :first)
      select('custom')
      fill_in('note', with: text_in_dialect)
      fill_in('custom', with: text_in_dialect)
      fill_in('dance_notes', with: text_in_dialect)
      fill_in('dance_preamble', with: text_in_dialect)
      fill_in('dance_hook', with: text_in_dialect)
      fill_in 'dance_title', with: 'Call Me'
      fill_in 'dance[choreographer_name]', with: 'Cary Ravitz'
      fill_in 'dance[start_type]', with: 'improper'
      click_on 'Save Dance'
      expect(page).to have_words('Dance was successfully created.')
      dance = Dance.last
      custom_figure = dance.figures.first
      expect(custom_figure['note']).to eq(text_in_canon)
      expect(custom_figure['parameter_values'].first).to eq(text_in_canon)
      expect(dance.notes).to eq(text_in_canon)
      expect(dance.preamble).to eq(text_in_canon)
      expect(dance.hook).to eq(text_in_canon)
    end
  end

  it 'users type text in their dialect and validation failures do not corrupt it' do
    with_login do |user|
      allow_any_instance_of(User).to receive(:dialect).and_return(JSLibFigure.test_dialect)
      text_in_dialect = 'darcy ravens'
      text_in_canon = 'gyre ladles'
      visit new_dance_path
      click_on('stand still', match: :first)
      select('custom')
      fill_in('note', with: "note #{text_in_dialect} note")
      fill_in('custom', with: "custom #{text_in_dialect} custom")
      fill_in('dance_notes', with: "notes #{text_in_dialect} notes")
      fill_in('dance_preamble', with: "preamble #{text_in_dialect} preamble")
      fill_in('dance_hook', with: "hook #{text_in_dialect} hook")
      click_on 'Save Dance'
      expect(page).to_not have_content('Dance was successfully created.')
      expect(page).to_not have_link("custom #{text_in_canon} custom note #{text_in_canon} note")
      expect(page).to have_link("custom #{text_in_dialect} custom note #{text_in_dialect} note")
      expect(find('#dance_notes').value).to eq("notes #{text_in_dialect} notes")
      expect(find('#dance_preamble').value).to eq("preamble #{text_in_dialect} preamble")
      expect(find('#dance_hook').value).to eq("hook #{text_in_dialect} hook")
    end
  end
end
