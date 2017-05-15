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
end
