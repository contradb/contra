require 'rails_helper'
require 'spec_helper'
require 'support/scrutinize_layout'

# from https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara :
include Warden::Test::Helpers
Warden.test_mode!

describe 'Creating dances' do
  before (:each) do
    @user = FactoryGirl.create(:user)
    login_as(@user, :scope => :user)
  end

  pending "Migrate to PG so this commented-out test can be run"
 # javascript driver requires a multi-threaded DB, and I just don't have the time. 
 # it "creates a new choreographer",  js: true do
 #    visit '/dances/new'
 #    fill_in "dance_title", with: "Call Me"
 #    fill_in "dance[choreographer_name]", with: "Cary Ravitz"
 #    fill_in "dance_start_type", with: "improper"
 #    click_button "Save Dance"
 #
 #    expect(page).to have_css("h1", text: "Call me")
 #    expect(page).to have_content("Cary Ravitz")
 #    expect(page).to have_content("improper")
 #  end
 # also write a test to create a choreographer with too-few-characters in their name, see how that works. 

end
