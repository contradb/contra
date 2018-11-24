# coding: utf-8
require 'rails_helper'

describe 'Showing dances', js: true do
  describe "lingo lines" do
    let (:dance) {FactoryGirl.create(:dance, preamble: 'men')}

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

  describe 'tags' do
    let (:dance) {FactoryGirl.create(:dance)}

    it 'button toggles creation of duts' do
      with_login do |user|
        tag = Tag.find_by(name: 'please review')
        visit dance_path(dance)
        click_on(tag.name)
        expect(page).to have_css('.btn.btn-primary', text: tag.name)
        expect(Dut.find_by(user: user, tag: tag, dance: dance)).to be_a(Dut)
        click_on(tag.name)
        expect(page).to have_css('.btn.btn-default', text: tag.name)
        expect(Dut.find_by(user: user, dance: dance, tag: tag)).to be(nil)
        click_on(tag.name)
        expect(page).to have_css('.btn.btn-primary', text: tag.name)
        expect(Dut.find_by(user: user, tag: tag, dance: dance)).to be_a(Dut)
      end
    end

    it 'without login, prompts' do
      visit dance_path(dance)
      click_on('verified')
      expect(page).to have_button('Login')
      expect(page).to have_current_path(new_user_session_path)
      user = FactoryGirl.create(:user)
      fill_in(:user_email, with: user.email)
      fill_in(:user_password, with: user.password)
      click_on('Login')
      expect(page).to have_css('h1', text: dance.title)
      expect(page).to have_css('.btn.btn-primary', text: 'verified')
    end
  end
end
