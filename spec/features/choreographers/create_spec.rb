require 'rails_helper'
require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!

describe 'Creating choreographer from index page' do

  it "with logged in user, goes to the New Choreographer page" do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)

    visit '/choreographers'
    click_link "New Choreographer"
    # assumes logged in, but I don't know how to do that yet -dm 12-16-2015
    expect(page).to have_content("New Choreographer")
  end

  it "sans logged in user, refuses to go the New Choreographer page" do

    visit '/choreographers'
    click_link "New Choreographer"
    # assumes logged in, but I don't know how to do that yet -dm 12-16-2015
    expect(page).to have_content("You need to sign in or sign up before continuing")
    expect(page).to have_content("Login")
  end


end
