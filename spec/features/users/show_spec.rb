require 'rails_helper'

describe "user show" do
  it "shows dances pubished as :all and :link but not :off" do
    user = FactoryGirl.create(:user)
    dances = [:off, :link, :all].reduce({}) do |dances, publishyness|
      dances.merge({publishyness =>
                  FactoryGirl.create(:dance, publish: publishyness, user: user, title: "dance-#{publishyness}.")})
    end
    visit user_path(user)
    expect(page).to_not have_link(dances.fetch(:off).title)
    expect(page).to have_link(dances.fetch(:link).title)
    expect(page).to have_link(dances.fetch(:all).title)
  end
end
