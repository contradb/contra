# coding: utf-8
require 'rails_helper'

describe 'Showing dances' do
  let (:dance) {FactoryGirl.create(:box_the_gnat_contra)}

  it 'displays fields ' do
    visit dance_path dance.id
    expect(page.body).to include dance.title
    expect(page.body).to include dance.choreographer.name
    expect(page.body).to include dance.start_type
    expect(page).to have_text ('neighbors balance & swing')
    expect(page).to have_text ('ladles allemande right 1½')
    expect(page.body).to include dance.notes
  end
end
