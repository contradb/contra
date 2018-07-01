require 'rails_helper'
require 'support/scrutinize_layout'

describe 'Creating program from index page' do

  it "with logged in user, goes to the New Program page" do
    with_login do
      visit programs_path
      click_link "New Program"

      expect(page).to have_selector("input[placeholder='Program Title']")
      expect(page).to have_selector("input[title='Program Title']")
      expect(page).to have_selector("button[title='add row']")
      expect(page).to have_selector("button[title='delete selected']")
      expect(page).to have_selector("button[title='select all']")
      expect(page).to have_selector("button[title='select none']")
      expect(page).to have_selector("button[title='move up']")
      expect(page).to have_selector("button[title='move down']")
      expect(page).to have_selector("button[title='move to top']")
      expect(page).to have_selector("button[title='move to bottom']")

      # this is comment 'bingo', see below...
      # expect(page).to have_selector("input[title='select']")
      # expect(page).to have_selector("input[title='dance']")
      # expect(page).to have_selector("input[title='additional text']")

      expect(page).to have_selector("button[type='submit']")
      scrutinize_layout page
    end
  end

  pending "should test that javascript populates the new program with a few fields"
  # to implement, see the comment labeled 'bingo' above

  it "without logged in user, refuses to go the New Program page" do
    visit '/programs'
    click_link "New Program"

    expect(page).to have_content("You need to sign in or sign up before continuing")
    scrutinize_layout page
  end
end
