# coding: utf-8
require 'rails_helper'
require 'login_helper'

describe 'Indexing dances' do
  it 'displays info and actions of my own dances' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit dances_path
      expect(page).to have_link(dance.title)
      expect(page).to have_link(dance.choreographer.name)
      expect(page).to have_link(dance.user.name)
      expect(page).to have_selector('a .glyphicon.glyphicon-duplicate')
      expect(page).to have_selector('a .glyphicon.glyphicon-edit')
      expect(page).to have_selector('a .glyphicon.glyphicon-trash')
    end
  end

  it 'displays info and actions of others\' dances' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra)
      visit dances_path
      expect(page).to have_link(dance.title)
      expect(page).to have_link(dance.choreographer.name)
      expect(page).to have_link(dance.user.name)
      expect(page).to have_selector('a .glyphicon.glyphicon-duplicate')
      expect(page).to_not have_selector('a .glyphicon.glyphicon-edit')
      expect(page).to_not have_selector('a .glyphicon.glyphicon-trash')
    end
  end

  it 'displays info and actions of any users dances when admin' do
    with_login(admin: true) do |admin|
      dance = FactoryGirl.create(:box_the_gnat_contra)
      visit dances_path
      expect(page).to have_link(dance.title)
      expect(page).to have_link(dance.choreographer.name)
      expect(page).to have_link(dance.user.name)
      expect(page).to have_selector('a .glyphicon.glyphicon-duplicate')
      expect(page).to have_selector('a .glyphicon.glyphicon-edit')
      expect(page).to have_selector('a .glyphicon.glyphicon-trash')
    end
  end
end



