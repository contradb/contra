# coding: utf-8
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
      expect(page).to have_text ('ladles allemande right 1½')
      expect(page.body).to include dance.notes
      expect(page).to have_current_path(edit_dance_path(dance.id))
    end
  end
  it 'editing a dance passes it\'s information through unchanged' do
    with_login do |user|
      dance1 = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit edit_dance_path dance1.id
      click_button 'Save Dance'
      dance2 = FactoryGirl.build_stubbed(:box_the_gnat_contra, user: user)
      dance1.reload
      expect(current_path).to eq dance_path dance1.id
      %w[title start_type figures_json notes].each do |message|
        expect(dance1.send message).to eql dance2.send message
      end
      expect(dance1.choreographer.name).to eql dance2.choreographer.name
    end
  end
end



