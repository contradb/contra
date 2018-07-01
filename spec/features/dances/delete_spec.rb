require 'rails_helper'
require 'support/scrutinize_layout'

describe 'Deleting dances' do
  let :user {FactoryGirl.create(:user)}
  let :chor {FactoryGirl.create(:choreographer)}
  let :hash {{user: user, choreographer: chor}}
  let! :live {FactoryGirl.create(:dance, (hash.merge title: "I am live"))}
  let! :dead {FactoryGirl.create(:dance, (hash.merge title: "I am dead"))}

  def find_dead_delete_link
    page.find(:css, "a[href=\"/dances/#{dead.id}\"][data-method=\"delete\"]")
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

  it "works from dance view" do
    with_login(user: user) do
      visit dance_path(dead)
      click_link "Delete"

      expect(page).to have_css("h1", text: user.name) # go back to user profile
      expect(page).to     have_content("I am live")
      expect(page).to_not have_content("I am dead")
    end
  end
end
