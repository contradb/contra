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
        visit dance_path(dance)
        click_on('please review')
        expect(page).to have_css('.btn.btn-primary', text: 'please review')
        dut = Dut.last
        expect(dut).to be_a(Dut)
        expect(dut.user_id).to eq(user.id)
        expect(dut.dance_id).to eq(dance.id)
        expect(dut.tag_id).to eq(Tag.find_by(name: 'please review').id)
      end
    end

    it 'without login, prompts'
  end
end
