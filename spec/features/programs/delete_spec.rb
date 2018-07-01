require 'rails_helper'

describe 'Deleting programs' do
  let :user {FactoryGirl.create(:user)}
  let! :live {FactoryGirl.create(:program, user: user, title: "I am live")}
  let! :dead {FactoryGirl.create(:program, user: user, title: "I am dead")}

  def find_dead_delete_link
    page.find(:css, "a[href=\"/programs/#{dead.id}\"][data-method=\"delete\"]")
  end

  it "works from programs index" do
    with_login(user: user) do
      visit programs_path
      find_dead_delete_link.click

      expect(page).to have_css("h1", text: "Programs") # go back to where we started
      expect(page).to     have_content("I am live")
      expect(page).to_not have_content("I am dead")
    end
  end

  it "works from user profile" do
    with_login(user: user) do
      visit user_path(user)
      find_dead_delete_link.click

      expect(page).to have_css("h1", text: user.name) # go back to where we started
      expect(page).to     have_content("I am live")
      expect(page).to_not have_content("I am dead")
    end
  end

  it "works from program view" do
    with_login(user: user) do
      visit program_path(dead)
      click_link "Delete"

      expect(page).to have_css("h1", text: user.name) # go back to user profile
      expect(page).to     have_content("I am live")
      expect(page).to_not have_content("I am dead")
    end
  end
end
