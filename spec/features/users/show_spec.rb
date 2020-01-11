require 'rails_helper'

describe "user show" do
  let (:user) { FactoryGirl.create(:user) }
  let (:dances) do 
    [:off, :link, :all].reduce({}) {|dances, publishyness|
      dances.merge({publishyness => FactoryGirl.create(:dance, publish: publishyness, user: user, title: "dance-#{publishyness}.")})
    }
  end

  it "shows dances split into two tables, based on :all and :link" do
    dances
    visit user_path(user)
    expect(page).to_not have_css("table a", text: dances[:off].title)
    expect(page).to have_css(".public-dances table a", text: dances[:all].title)
    expect(page).to have_css('.sketchbook-dances h3', text: 'Sketchbook')
    expect(page).to have_css('.sketchbook-dances p', text: "This is for dances that aren't ready to call. They're not discoverable from the main dance search page.")
    expect(page).to have_css(".sketchbook-dances table a", text: dances[:link].title)
  end

  it "doesn't show the sketchbook table if the user doesn't have one" do
    visit user_path(user)
    expect(page).to_not have_text("Sketchbook")
    expect(page).to_not have_css(".sketchbook-dances")
  end

  describe "private dances" do
    it "when logged in shows private dances" do
      dances
      with_login(user: user) do
        visit user_path(user)
        expect(page).to have_css('.private-dances h3', text: 'Private Dances')
        expect(page).to have_css(".private-dances table a", text: dances[:off].title)
      end
    end

    it "doesn't show table if there are none" do
      visit user_path(user)
      expect(page).to_not have_text("Private Dances")
      expect(page).to_not have_css(".private-dances")
    end

    it "when logged in but have nonone, don't show table" do
      dances
      dances[:off].destroy!
      with_login(user: user) do
        visit user_path(user)
        expect(page).to_not have_css('.private-dances h3', text: 'Private Dances')
        expect(page).to_not have_css(".private-dances table a")
      end
    end
  end
end
