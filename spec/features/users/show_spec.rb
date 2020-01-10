require 'rails_helper'

describe "user show" do
  it "shows dances pubished as :all and :link but not :off" do
    user = FactoryGirl.create(:user)
    dances = [:off, :link, :all].reduce({}) do |dances, publishyness|
      dances.merge({publishyness =>
                  FactoryGirl.create(:dance, publish: publishyness, user: user, title: "dance-#{publishyness}.")})
    end
    visit user_path(user)
    expect(page).to_not have_css("table a", text: dances[:off].title)
    expect(page).to have_css(".public-dances table a", text: dances[:all].title)
    expect(page).to have_css('.sketchbook-dances h3', text: 'Sketchbook')
    expect(page).to have_css('.sketchbook-dances p', text: "This is for dances that aren't ready to call. They're not discoverable from the main dance search page.")
    expect(page).to have_css(".sketchbook-dances table a", text: dances[:link].title)
    # TODO: show headers to explain why 2 types of dance tables
    # TODO: only show 2nd table & header if it is non-empty
  end

  it "doesn't show the sketchbook if the user doesn't have one" do
    user = FactoryGirl.create(:user)
    visit user_path(user)
    expect(page).to_not have_text("Sketchbook")
    expect(page).to_not have_css(".sketchbook-dances")
  end
end
