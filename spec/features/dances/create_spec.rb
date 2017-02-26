require 'rails_helper'
require 'login_helper'
require 'support/scrutinize_layout'


describe 'Creating dances', js: true do
  it 'creates a new dance with non-javascript data' do
    with_login do
      visit '/dances/new'
      expect(page.text).to include 'There\'s a lot of ink spilled over "gentlemen" versus "men" versus "leads".'
      fill_in 'dance_title', with: 'Call Me'
      fill_in 'dance[choreographer_name]', with: 'Cary Ravitz'
      fill_in 'dance[start_type]', with: 'improper'
      click_button 'Save Dance'
      
      expect(page).to have_css('h1', text: 'Call Me')
      expect(page).to have_content('Cary Ravitz')
      expect(page).to have_content('improper')
    end
  end

  it 'has working A1/B2 labels' do
    with_login do
      visit '/dances/new'
      expect(page.text).to include 'There\'s a lot of ink spilled over "gentlemen" versus "men" versus "leads".'
      fill_in 'dance_title', with: 'Call Me'
      fill_in 'dance[choreographer_name]', with: 'Cary Ravitz'
      fill_in 'dance[start_type]', with: 'improper'
      
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

      7.times { click_button 'Remove Figure' }

      click_on('empty figure')
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
        expect(page).to have_css('#figure-3', text: 'circle to the left 5 places')
        expect(page).to have_css('#figure-4', text: 'circle to the left 5 places')
      end
    end

    it 'delete' do
      with_login do
        visit '/dances/new'
        make_eight_circle_figures
        find('#figure-menu-4').click # 'circle to the left 5 places'
        click_on 'Delete'
        expect(page).to have_text "circle to the left 1 place"
        expect(page).to have_text "circle to the left 2 places"
        expect(page).to have_text "circle to the left 3 places"
        expect(page).to have_text "circle to the left 4 places"
        expect(page).to_not have_text "circle to the left 5 places"
        expect(page).to have_text "circle to the left 6 places"
        expect(page).to have_text "circle to the left 7 places"
        expect(page).to have_text "circle to the left 8 places"
      end
    end

    it 'up' do
      with_login do
        visit '/dances/new'
        make_eight_circle_figures
        find('#figure-menu-4').click # 'circle to the left 5 places'
        click_on 'Up 2'
        expect(page).to have_text ['A1',
                                   'circle to the left 1 place',
                                   'circle to the left 2 places',
                                   'A2',
                                   'circle to the left 5 places',
                                   'circle to the left 3 places',
                                   'B1',
                                   'circle to the left 4 places',
                                   'circle to the left 6 places',
                                   'B2',
                                   'circle to the left 7 places',
                                   'circle to the left 8 places'].join(' ')
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
end
