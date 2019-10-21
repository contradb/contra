require 'rails_helper'

describe 'Choreographer show' do
  let (:choreographer) { FactoryGirl.create(:choreographer) }
  let (:dance_off) { FactoryGirl.create(:dance, choreographer: choreographer, title: "Off Dance", publish: :off)}
  let (:dance_link) { FactoryGirl.create(:dance, choreographer: choreographer, title: "Link Dance", publish: :link)}
  let (:dance_all) { FactoryGirl.create(:dance, choreographer: choreographer, title: "All Dance", publish: :all)}
  let (:not_my_dance) { FactoryGirl.create(:dance, title: "Not My Dance", publish: :all)}

  it "Displays that choreographer's public dances" do
    dance_all
    dance_link
    dance_off
    not_my_dance
    
    visit choreographer_path(choreographer)
    expect(page).to have_link(dance_all.title)
    expect(page).to_not have_link(dance_link.title)
    expect(page).to_not have_link(dance_off.title)
    expect(page).to_not have_link(not_my_dance.title)
  end

  it "Displays that choreographer's publishing information" do
    friendly = FactoryGirl.create(:friendly_choreographer)
    visit choreographer_path(friendly)
    expect(page).to have_link(friendly.website)
    expect(page).to have_text("Permission to publish dances: #{friendly.publish.titleize}")
  end
end
