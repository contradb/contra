require 'rails_helper'

describe 'Choreographer show' do
  let (:choreographer) { FactoryGirl.create(:choreographer) }
  let (:dance_publish) { FactoryGirl.create(:dance, choreographer: choreographer, title: "Publish Dance", publish: true)}
  let (:dance_private) { FactoryGirl.create(:dance, choreographer: choreographer, title: "Private Dance", publish: false)}
  let (:not_my_dance) { FactoryGirl.create(:dance, title: "Not My Dance", publish: true)}

  it "Displays that choreographer's public dances" do
    dance_publish
    dance_private
    not_my_dance
    
    visit choreographer_path(choreographer)
    expect(page).to have_link(dance_publish.title)
    expect(page).to_not have_link(dance_private.title)
    expect(page).to_not have_link(not_my_dance.title)
  end

  it "Displays that choreographer's publishing information" do
    friendly = FactoryGirl.create(:friendly_choreographer)
    visit choreographer_path(friendly)
    expect(page).to have_link(friendly.website)
    expect(page).to have_text("Permission to publish dances: #{friendly.publish.titleize}")
  end
end
