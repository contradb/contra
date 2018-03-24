# coding: utf-8
require 'rails_helper'
require 'login_helper'

describe 'Copying dances', js: true do
  it 'displays attributes of an existing dance' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit new_dance_path copy_dance_id: dance.id
      expect(page.body).to include(dance.title)
      expect(page.body).to include(dance.choreographer.name)
      expect(page.body).to include(dance.start_type)
      expect(page.body).to include(dance.hook)
      expect(page.body).to include(dance.preamble)
      expect(page).to_not match(/Becket/i)
      expect(page).to have_text('neighbors balance & swing')
      expect(page).to have_text('ladles allemande right 1½')
      expect(page.body).to include(dance.preamble)
      expect(page.body).to include(dance.notes)
      expect(page).to have_current_path(new_dance_path copy_dance_id: dance.id)
    end
  end

  it 'editing a dance passes it\'s information through unchanged' do
    with_login do |user|
      dance1 = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit new_dance_path copy_dance_id: dance1.id
      click_button 'Save Dance'

      dance2 = Dance.last
      expect(current_path).to eq dance_path dance2.id
      %w[start_type figures_json hook preamble notes].each do |message|
        expect(dance2.send message).to eql dance1.send message
      end
      expect(dance2.title).to eql "#{dance1.title} variation"
      expect(dance2.choreographer.name).to eql dance1.choreographer.name
    end
  end

  it 'applies dialect' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)
      allow_any_instance_of(User).to receive(:dialect).and_return(JSLibFigure.test_dialect)
      visit new_dance_path copy_dance_id: dance.id
      expect(page).to have_text('ravens almond right 1½')
    end
  end
end



