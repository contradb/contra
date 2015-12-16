require 'rails_helper'
require 'spec_helper'

describe 'Creating user from welcome page' do
  it "goes to the Sign Up page on success" do
    visit '/'
    click_link "Sign Up"
    # assumes logged in, but I don't know how to do that yet -dm 12-16-2015
    expect(page).to have_content("Sign Up")
    expect(page).to have_content("Email:")
    expect(page).to have_content("Name:")
    expect(page).to have_content("Password:")
  end
end
