require 'rails_helper'

# from https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara :
include Warden::Test::Helpers
Warden.test_mode!

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
end
