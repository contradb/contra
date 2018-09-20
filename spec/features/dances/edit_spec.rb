# coding: utf-8
require 'rails_helper'

describe 'Editing dances' do
  describe 'authorization' do
    it 'different users' do
      with_login do |user|
        dance = FactoryGirl.create(:dance)
        visit(edit_dance_path(dance))
        expect(page).to have_content("You don't have access to that")
        expect(page).to have_current_path(root_path)
      end
    end

    it 'not logged in' do
      dance = FactoryGirl.create(:dance)
      visit(edit_dance_path(dance))
      # expect(page).to have_content("You don't have access to that - maybe you would if you logged in?") # broken - overwritten by a devise warning
      expect(page).to have_current_path(new_user_session_path)
    end

    it 'admin' do
      with_login(admin: true) do |user|
        dance = FactoryGirl.create(:dance)
        visit(edit_dance_path(dance))
        expect(page).to have_current_path(edit_dance_path(dance))
      end
    end
  end
end
