# coding: utf-8
require 'rails_helper'
require 'login_helper'

describe 'Editing dances', js: true do
  it 'displays attributes of an existing dance' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit edit_dance_path dance.id
      expect(page.body).to include(dance.title)
      expect(page.body).to include(dance.choreographer.name)
      expect(page.body).to include(dance.start_type)
      expect(page.body).to include(dance.hook)
      expect(page.body).to include(dance.preamble)
      expect(page.body).to_not match(/Becket/i)
      expect(page).to have_text('neighbors balance & swing')
      expect(page).to have_text('ladles allemande right 1½')
      expect(page.body).to include dance.notes
      expect(page).to have_current_path(edit_dance_path(dance.id))
    end
  end
  it 'editing a dance passes it\'s information through unchanged' do
    with_login do |user|
      choreographer = FactoryGirl.create(:choreographer, name: 'Becky Hill')
      dance1 = FactoryGirl.create(:box_the_gnat_contra, user: user, choreographer: choreographer)
      visit edit_dance_path dance1.id
      click_button 'Save Dance'
      dance2 = FactoryGirl.build(:box_the_gnat_contra, user: user, choreographer: choreographer)
      dance1.reload
      expect(current_path).to eq dance_path dance1.id
      %w[title start_type figures_json hook preamble notes].each do |message|
        expect(dance1.send message).to eql dance2.send message
      end
      expect(dance1.choreographer.name).to eql dance2.choreographer.name
    end
  end
  it 'editing a dance saves form values (except figure editor edits)' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit edit_dance_path dance.id
      fill_in 'dance_title', with: 'Call Me'
      fill_in 'dance[choreographer_name]', with: 'Cary Ravitz'
      fill_in 'dance[start_type]', with: 'Beckett'
      fill_in 'dance[hook]', with: 'wombatty'
      fill_in 'dance[preamble]', with: 'prerambling'
      fill_in 'dance[notes]', with: 'notey'
      choose 'Publish'
      click_button 'Save Dance'
      dance.reload

      expect(dance.title).to eq('Call Me')
      expect(dance.choreographer.name).to eq('Cary Ravitz')
      expect(dance.start_type).to eq('Beckett')
      expect(dance.hook).to eq('wombatty')
      expect(dance.preamble).to eq('prerambling')
      expect(dance.notes).to eq('notey')
    end
  end
end



