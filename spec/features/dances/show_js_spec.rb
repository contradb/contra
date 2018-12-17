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

    describe 'toggling' do
      it 'zero duts initially' do
        with_login do |user|
          tag = Tag.find_by(name: 'verified')

          # handle = Capybara.page.driver.current_window_handle
          # Capybara.page.driver.resize_window_to(handle, 800, 1200)

          visit dance_path(dance)

          expect(page).to_not have_css(".#{tag.glyphicon}")
          expect(page).to have_css('.tag-label-untagged', text: tag.name)
          expect(page).to have_text(tag.name + ' × 0')
          # expect(Dut.find_by(dance: dance, user: user, tag: tag)).to be(nil)
          # expect to have no icon

          toggle_tag(tag)

          expect(page).to have_css(".#{tag.glyphicon}")
          expect(page).to_not have_css('.tag-label-untagged', text: tag.name)
          expect(page).to have_text(tag.name + ' × 1')
          # expect(Dut.find_by(dance: dance, user: user, tag: tag)).to_not be(nil)
          # expect to have icon

          toggle_tag(tag)
          expect(page).to_not have_css(".#{tag.glyphicon}")
          expect(page).to have_css('.tag-label-untagged', text: tag.name)
          expect(page).to have_text(tag.name + ' × 0')
          # expect(Dut.find_by(dance: dance, user: user, tag: tag)).to be(nil)
          # expect to have no icon

          # Dave put away nog
        end
      end

      it 'other-people duts initially' do
        with_login do |user|
          tag = Tag.find_by(name: 'verified')
          initial_dut_count = 2

          initial_dut_count.times {FactoryGirl.create(:dut, tag: tag, dance: dance)}

          visit dance_path(dance)

          expect(page).to have_css(".#{tag.glyphicon}")
          expect(page).to_not have_css('.tag-label-untagged', text: tag.name)
          expect(page).to have_text("#{tag.name} × #{initial_dut_count}")

          toggle_tag(tag)

          expect(page).to have_css(".#{tag.glyphicon}")
          expect(page).to_not have_css('.tag-label-untagged', text: tag.name)
          expect(page).to have_text("#{tag.name} × #{initial_dut_count + 1}")
        end
      end
    end

    def toggle_tag(tag)
      page.find(".tag-constellation[data-tag-id='#{tag.id}'] .toggle-handle").click
    end

    [0, 1].each do |other_dut_count|
      it "loads with buttons toggled if a dut already exists (with #{other_dut_count} other duts)" do
        tag = Tag.find_by(name: 'broken') or raise "expected this to be created for reasons I don't recall"
        tag_clicked_label = "#{tag.name} ×#{1 + other_dut_count}"
        tag_unclicked_label = if other_dut_count == 0 then tag.name else "#{tag.name} ×#{other_dut_count}" end

        with_login do |user|
          FactoryGirl.create(:dut, tag: tag, user: user, dance: dance)
          other_dut_count.times {FactoryGirl.create(:dut, tag: tag, dance: dance)}
          visit dance_path(dance)
          expect(page).to have_css('.btn.btn-primary', text: tag_clicked_label)
          expect(page).to have_css('.btn.btn-primary span.glyphicon-ok')
          click_on(tag.name)
          expect(page).to have_css('.btn.btn-default', text: tag_unclicked_label)
          expect(Dut.find_by(user: user, dance: dance, tag: tag)).to be(nil)
        end
      end
    end

    it 'shows a waiting icon' do
      with_login do |user|
        tag = Tag.find_by(name: 'verified')
        visit dance_path(dance)
        expect(page).to_not have_css('.btn.btn-default span.glyphicon-time')
        click_on(tag.name)
        expect(page).to have_css('.btn.btn-default span.glyphicon-time') # if this spec gets flaky, maybe stub the controller to never return

        button = page.find('.btn.btn-primary', text: tag.name)
        expect(button).to_not have_css('.glyphicon-time')
        expect(button).to have_css('.glyphicon-ok')

        click_on(tag.name)
        button = page.find('.btn.btn-default', text: tag.name)
        expect(button).to_not have_css('span')
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
