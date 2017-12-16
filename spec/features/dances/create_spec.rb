require 'rails_helper'
require 'login_helper'
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

  it 'has working A1/B2 labels' do
    with_login do
      visit '/dances/new'
      expect(page).to have_current_path(new_dance_path)
      fill_in 'dance_title', with: 'Call Me'
      fill_in 'dance[choreographer_name]', with: 'Cary Ravitz'
      fill_in 'dance[start_type]', with: 'improper'
      
      expect(page).to have_css('#figure-0')
      find('#figure-0').click
      7.times { click_button 'Remove Figure' }

      click_button 'Save Dance'

      expect(page).to have_css('h1', text: 'Call Me')
      expect(page).to have_content('A1')
      expect(page).to_not have_content('A2')
      expect(page).to_not have_content('B1')
      expect(page).to_not have_content('B2')

      click_on 'Edit'

      2.times { click_button 'Add Figure' }

      click_button 'Save Dance'

      expect(page).to have_content('A1')
      expect(page).to have_content('A2')
      expect(page).to_not have_content('B1')
      expect(page).to_not have_content('B2')
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
      7.times { click_button 'Remove Figure' }

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

    it 'delete' do
      with_login do
        visit '/dances/new'
        make_eight_circle_figures
        find('#figure-menu-4').click # 'circle to the left 5 places'
        click_on 'Delete'
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
        expect(page).to have_text ['A1',
                                   'circle left 1 place',
                                   'circle left 2 places',
                                   'A2',
                                   'circle left 5 places',
                                   'circle left 3 places',
                                   'B1',
                                   'circle left 4 places',
                                   'circle left 6 places',
                                   'B2',
                                   'circle left 7 places',
                                   'circle left 8 places'].join(' ')
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
        expect(page).to have_content('empty figure', count: 8)
        find('#figure-0').click
        select('chain')
        click_button('Add Figure')
        expect(page).to have_content("A1 ladles chain empty figure move note")
        click_button('Add Figure')
        expect(page).to have_content("A1 ladles chain empty figure A2 empty figure move note")
      end
    end

    it 'adds a figure to the beginning and selects it if there is no selection' do
      with_login do
        visit '/dances/new'
        find('#figure-0').click
        select('chain')
        click_link('ladles chain')
        click_button('Add Figure')
        expect(page).to have_content("A1 empty figure move note ladles chain")
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
        expect(page).to have_content('A1 ladles chain')
        click_button('Remove Figure')
        expect(page).to_not have_content('ladies chain')
        expect(page).to have_content('A1 ____ do si do once move who')
      end
    end

    it 'removes the selection and selects the next-up figure if there is no next down figure' do
      with_login do
        visit '/dances/new'
        expect(page).to have_css('#figure-7')
        find('#figure-7').click
        select('do si do')
        expect(page).to have_content('B2 empty figure ____ do si do')
        click_button('Remove Figure')
        expect(page).to_not have_content('do si do')
        expect(page).to have_content('B2 empty figure move')
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
          click_button('Remove Figure')
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
        find('#figure-0').click
        5.times do
          click_button('Remove Figure')
        end
        select('custom')
        click_link('custom')
        expect(page).to have_content('A1 custom empty figure A2 empty figure Notes')
        click_button('Rotate Figures')
        expect(page).to have_content('A1 empty figure custom A2 empty figure Notes')
        click_button('Rotate Figures')
        expect(page).to have_content('A1 empty figure empty figure A2 custom Notes')
        click_button('Rotate Figures')
        expect(page).to have_content('A1 custom empty figure A2 empty figure Notes')
      end
    end
  end
end
