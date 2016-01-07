require 'rails_helper'
require 'spec_helper'
require 'support/scrutinize_layout'

# from https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara :
include Warden::Test::Helpers
Warden.test_mode!

describe 'Deleting dances' do
  before (:each) do
    @user = FactoryGirl.create(:user)
    login_as(@user, :scope => :user)
    chor = FactoryGirl.create(:choreographer)
    hash = {user: @user, choreographer: chor}
    @live = FactoryGirl.create(:dance, (hash.merge title: "I am live"))
    @dead = FactoryGirl.create(:dance, (hash.merge title: "I am dead"))
  end

  def find_dead_delete_link
    page.find(:css, "a[href=\"/dances/#{@dead.id}\"][data-method=\"delete\"]")
  end

  it "works from dance index" do
    visit '/dances'
    find_dead_delete_link.click

    expect(page).to have_css("h1", text: "Dances") # go back to where we started
    expect(page).to     have_content("I am live")
    expect(page).to_not have_content("I am dead")
  end

  it "works from user profile" do
    visit "/users/#{@user.id}"
    find_dead_delete_link.click

    expect(page).to have_css("h1", text: @user.name) # go back to where we started
    expect(page).to     have_content("I am live")
    expect(page).to_not have_content("I am dead")
  end

  it "works from dance view" do
    visit "/dances/#{@dead.id}"
    click_link "Delete"

    expect(page).to have_css("h1", text: @user.name) # go back to user profile
    expect(page).to     have_content("I am live")
    expect(page).to_not have_content("I am dead")
  end
end
