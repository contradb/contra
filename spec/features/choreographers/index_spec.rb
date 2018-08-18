require 'rails_helper'

describe 'Choreographer index' do
  it "Displays a choreographer's information" do
    choreographer = FactoryGirl.create(:friendly_choreographer)

    visit choreographers_path

    expect(page).to have_link(choreographer.name, href: choreographer_path(choreographer))
    expect(page).to have_link(choreographer.website)
    expect(page).to have_text(choreographer.publish.titleize)
    expect(page).to have_link(choreographer.website_label, href: choreographer.website_url)
  end

  it "Displays dance count visible to this user only" do
    with_login do |user|
      choreographer = FactoryGirl.create(:friendly_choreographer)
      FactoryGirl.create(:dance, publish: true, choreographer: choreographer, user: user) # visible #1
      FactoryGirl.create(:dance, publish: false, choreographer: choreographer, user: user) # visible #2
      FactoryGirl.create(:dance, publish: false, choreographer: choreographer) # invisible

      visit choreographers_path

      expect(page).to have_words("#{choreographer.name} 2")
      expect(page).to_not have_words("#{choreographer.name} 1")
      expect(page).to_not have_words("#{choreographer.name} 3")
    end
  end
end
