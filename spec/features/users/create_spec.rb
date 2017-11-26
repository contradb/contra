require 'rails_helper'
require 'support/scrutinize_layout'

describe 'Creating user from welcome page' do
  it "Splash page links to Create Dance, which actually prompts for login" do
    visit '/'
    scrutinize_layout page
    click_link "New Dance"
    expect(page).to have_content("You need to sign in or sign up before continuing.")
    expect(page).to have_content("Email:")
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
    expect(current_url).to eq('http://www.example.com/') # is the splash page
    expect(page).to have_content("Find Dances") 
    scrutinize_layout page
  end

  it "First user is created as admin, second is not" do
    visit '/users/sign_up'
    fill_in "user_email",                 with: "admin@yahoo.com"
    fill_in "user_name",                  with: "admin"
    fill_in "user_password",              with: "testing password 1234"
    fill_in "user_password_confirmation", with: "testing password 1234"
    click_button "Sign Up"

    click_link 'logout'

    visit '/users/sign_up'
    fill_in "user_email",                 with: "user@yahoo.com"
    fill_in "user_name",                  with: "user"
    fill_in "user_password",              with: "testing password 1234"
    fill_in "user_password_confirmation", with: "testing password 1234"
    click_button "Sign Up"

    expect(User.find_by(email: "admin@yahoo.com").admin?).to be(true)
    expect(User.find_by(email: "user@yahoo.com").admin?).to be(false)
  end
end
