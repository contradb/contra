# coding: utf-8
require 'rails_helper'
require 'login_helper'

describe 'Copying dances', js: true do
  it 'displays attributes of an existing dance' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit new_dance_path copy_dance_id: dance.id
      expect(page.body).to include "Box the Gnat Contra variation" # dance.title
      expect(page.body).to include "Becky Hill" # dance.choreographer.name
      expect(page.body).to include "improper" # dance.start_type
      expect(page.body).to_not match /Becket/i
      expect(page).to have_text ('neighbors balance & swing')
      expect(page).to have_text ('ladles allemande by the right 1½')
      expect(page.body).to include dance.notes
      expect(page).to have_text 'There\'s a lot of ink spilled over "gentlemen" versus "men" versus "leads".'
    end
  end
  it 'editing a dance passes it\'s information through unchanged' do
    with_login do |user|
      dance1 = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit new_dance_path copy_dance_id: dance1.id
      click_button 'Save Dance'

      dance2 = Dance.last
      expect(current_path).to eq dance_path dance2.id
      %w[start_type figures_json notes].each do |message|
        expect(dance2.send message).to eql dance1.send message
      end
      expect(dance2.title).to eql "#{dance1.title} variation"
      expect(dance2.choreographer.name).to eql dance1.choreographer.name
    end
  end
end



