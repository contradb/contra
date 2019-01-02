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

    it 'bootstrap_color attribute works' do
      with_login do |user|
        tag = Tag.find_by(name: 'broken')
        FactoryGirl.create(:dut, user: user, tag: tag, dance: dance)
        visit dance_path(dance)
        expect(tag.bootstrap_color).to eq('danger')
        expect(page).to have_css(".glyphicon.#{tag.glyphicon}.text-#{tag.bootstrap_color}")
        expect(page).to have_css("input[type='checkbox'][data-onstyle=#{tag.bootstrap_color.inspect}]", visible: false)
      end
    end

    describe 'bootstrap toggle' do
      it 'zero tags initially' do
        with_login do |user|
          tag = Tag.find_by(name: 'verified')

          visit dance_path(dance)

          expect(page).to_not have_css(".#{tag.glyphicon}")
          expect(page).to have_css('.tag-label-untagged', text: tag.name)
          expect(page).to have_text(tag.name + ' × 0')
          expect(page).to have_text(tag.off_sentence)
          expect(Dut.find_by(dance: dance, user: user, tag: tag)).to eq(nil)

          toggle_tag(tag)

          expect(page).to_not have_css('glyphicon-time');
          expect(page).to have_css(".#{tag.glyphicon}")
          expect(page).to_not have_css('.tag-label-untagged', text: tag.name)
          expect(page).to have_text(tag.name + ' × 1')
          expect(page).to have_text("you #{tag.on_verb} #{tag.on_phrase}")
          sleep(0.125)
          expect(page).to_not have_css('glyphicon-time')
          expect(Dut.find_by(dance: dance, user: user, tag: tag)).to_not eq(nil)

          toggle_tag(tag)

          expect(page).to_not have_css(".#{tag.glyphicon}")
          expect(page).to_not have_css('glyphicon-time');
          expect(page).to have_css('.tag-label-untagged', text: tag.name)
          expect(page).to have_text(tag.name + ' × 0')
          expect(page).to have_text(tag.off_sentence)
          sleep(0.125)
          expect(page).to_not have_css('glyphicon-time')
          expect(Dut.find_by(dance: dance, user: user, tag: tag)).to eq(nil)
        end
      end

      it "other-people's tags already exist" do
        with_login do |user|
          tag = Tag.find_by(name: 'verified')
          expect(tag.on_verb).to eq("have called")
          expect(tag.on_phrase).to eq("this transcription")
          initial_dut_count = 2

          initial_dut_count.times {FactoryGirl.create(:dut, tag: tag, dance: dance)}

          visit dance_path(dance)

          expect(page).to have_css(".#{tag.glyphicon}")
          expect(page).to_not have_css('.tag-label-untagged', text: tag.name)
          expect(page).to have_text("#{tag.name} × #{initial_dut_count}")
          expect(page).to have_text("2 users have called this transcription")
          expect(page).to_not have_text("3 users have called this transcription")

          toggle_tag(tag)

          expect(page).to_not have_css('glyphicon-time')
          expect(page).to have_css(".#{tag.glyphicon}")
          expect(page).to_not have_css('.tag-label-untagged', text: tag.name)
          expect(page).to have_text("#{tag.name} × #{initial_dut_count + 1}")
          expect(page).to_not have_text("2 users have called this transcription")
          expect(page).to have_text("3 users have called this transcription")
        end
      end

      it "loads toggled when you've already made a dut" do
        with_login do |user|
          tag = Tag.find_by(name: 'verified')
          expect(tag.on_verb).to eq("have called")
          expect(tag.on_phrase).to eq("this transcription")
          FactoryGirl.create(:dut, tag: tag, dance: dance, user: user)

          visit dance_path(dance)

          expect(page).to have_css(".#{tag.glyphicon}")
          expect(page).to_not have_css('.tag-label-untagged', text: tag.name)
          expect(page).to have_text("#{tag.name} × 1")
          expect(page).to have_text("you have called this transcription")
          expect(find(".tag-constellation[data-tag-id='#{tag.id}']").find('input', visible: false)).to be_checked

          toggle_tag(tag)

          expect(page).to_not have_css('glyphicon-time')
          expect(page).to_not have_css(".#{tag.glyphicon}")
          expect(page).to have_css('.tag-label-untagged', text: tag.name)
          expect(page).to have_text("#{tag.name} × 0")
          expect(page).to have_text(tag.off_sentence)
          expect(find(".tag-constellation[data-tag-id='#{tag.id}']").find('input', visible: false)).to_not be_checked
        end
      end
    end

    def toggle_tag(tag)
      page.find(".tag-constellation[data-tag-id='#{tag.id}'] .toggle-handle").click
    end

    xit 'shows a waiting icon' do
      raise 'todo'
    end

    xit 'without login, prompts' do
      visit dance_path(dance)
      raise 'todo'
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
