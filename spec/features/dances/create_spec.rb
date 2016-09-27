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

      choose('empty figure')
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
end
