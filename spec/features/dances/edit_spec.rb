require 'rails_helper'
require 'login_helper'

describe 'Editing dances', js: true do
  it 'displays attributes of an existing dance' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit edit_dance_path dance.id
      expect(page.body).to include "Box the Gnat Contra" # dance.title
      expect(page.body).to include "Becky Hill" # dance.choreographer.name
      expect(page.body).to include "improper" # dance.start_type
      expect(page.body).to_not match /Becket/i
      expect(page).to have_text ('neighbors balance & swing')
      expect(page.body).to include dance.notes
      expect(page).to have_text 'There\'s a lot of ink spilled over "gentlemen" versus "men" versus "leads".'
    end
  end
end



