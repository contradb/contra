require 'rails_helper'
require 'spec_helper'

describe 'Creating user from welcome page' do
  it "Splash page links to Sign Up page" do
    visit '/'
    click_link "Sign Up"
    expect(page).to have_content("Sign Up")
    expect(page).to have_content("Email:")
    expect(page).to have_content("Name:")
    expect(page).to have_content("Password:")
  end

  it "Sign Up page works" do
    visit '/users/sign_up'
    expect(page).to have_content("Sign Up")
    expect(page).to have_content("Email:")
    expect(page).to have_content("Name:")
    expect(page).to have_content("Password:")
    fill_in "user_email",                 with: "forgedmail@bog.us"
    fill_in "user_name",                  with: "Forgedmail at Bog.us"
    fill_in "user_password",              with: "testing password 1234"
    fill_in "user_password_confirmation", with: "testing password 1234"
    click_button "Sign Up"
  end


end
