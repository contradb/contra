require 'rails_helper'
require 'spec_helper'
require 'support/scrutinize_layout'

# from https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara :
include Warden::Test::Helpers
Warden.test_mode!

describe 'Creating program from index page' do

  it "with logged in user, goes to the New Choreographer page" do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)

    visit '/programs'
    click_link "New Program"

    expect(page).to have_selector("input[value='New Program']")
    scrutinize_layout page
  end

  it "sans logged in user, refuses to go the New Choreographer page" do

    visit '/programs'
    click_link "New Program"

    expect(page).to have_content("You need to sign in or sign up before continuing")
    expect(page).to have_content("Login")
    scrutinize_layout page
  end
end
