# coding: utf-8
require 'rails_helper'

describe 'Showing dances', js: true do
  let (:dance) {FactoryGirl.create(:dance, preamble: 'men')}
  describe "lingo lines" do
    it "validation toggles" do
      visit dance_path(dance)
      expect(page).to have_css('.no-lingo-lines s', text: 'men')
      find('label', text: 'Clean').click
      expect(page).to_not have_css('.no-lingo-lines s', text: 'men')
      expect(page).to have_css('s', text: 'men')
      find('label', text: 'Validate').click
      expect(page).to have_css('.no-lingo-lines s', text: 'men')
    end

    it "on by default for admin" do
      with_login(admin: true) do
        visit dance_path(dance)
        expect(page).to_not have_css('.no-lingo-lines s', text: 'men')
      end
    end
  end
end
