require 'rails_helper'
require 'spec_helper'
require 'support/scrutinize_layout'

describe 'Creating user from welcome page' do
  it "Splash page links to Sign Up page" do
    visit '/'
    scrutinize_layout page
    click_link "Sign Up"
    expect(page).to have_content("Sign Up")
    expect(page).to have_content("Email:")
    expect(page).to have_content("Name:")
    expect(page).to have_content("Password:")
    scrutinize_layout page
  end

  it "Sign Up page works" do
    visit '/users/sign_up'
    scrutinize_layout page
    expect(page).to have_content("Sign Up")
    expect(page).to have_content("Email:")
    expect(page).to have_content("Name:")
    expect(page).to have_content("Password:")
    fill_in "user_email",                 with: "forgedmail@bog.us"
    fill_in "user_name",                  with: "Forgedmail at Bog.us"
    fill_in "user_password",              with: "testing password 1234"
    fill_in "user_password_confirmation", with: "testing password 1234"
    click_button "Sign Up"
    expect(page).to have_content("Welcome! You have signed up successfully")
    expect(page).to have_content("Find and Share Contra Dances") # is the splash page
    scrutinize_layout page
  end

end
