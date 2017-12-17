# coding: utf-8
require 'rails_helper'
require 'login_helper'

describe 'Showing dances' do

  it 'displays fields' do
    dance = FactoryGirl.create(:box_the_gnat_contra)
    visit dance_path dance.id
    expect(page.body).to include dance.title
    expect(page.body).to include dance.hook
    expect(page.body).to include dance.choreographer.name
    expect(page.body).to include dance.start_type
    expect(page.body).to include dance.preamble
    expect(page).to have_text ('neighbors balance & swing')
    expect(page).to have_text ('ladles allemande right 1½')
    expect(page.body).to include dance.notes
  end

  describe 'actions buttons' do
    it 'has only the copy button if we do not own the dance' do
      with_login do |user|
        dance = FactoryGirl.create(:dance)
        visit dance_path dance.id
        expect(page).to have_link('Copy')
        expect(page).to_not have_link('Edit')
        expect(page).to_not have_link('Delete')
      end
    end

    it 'has copy, edit, and delete buttons if we do own the dance' do
      with_login do |user|
        dance = FactoryGirl.create(:dance, user: user)
        visit dance_path dance.id
        expect(page).to have_link('Copy')
        expect(page).to have_link('Edit')
        expect(page).to have_link('Delete')
      end
    end

    it 'has copy, edit, and delete buttons if we are an admin' do
      with_login(admin: true) do |user|
        dance = FactoryGirl.create(:dance)
        visit dance_path dance.id
        expect(page).to have_link('Copy')
        expect(page).to have_link('Edit')
        expect(page).to have_link('Delete')
      end
    end
  end
end
