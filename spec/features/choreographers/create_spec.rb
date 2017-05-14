require 'rails_helper'
require 'spec_helper'
require 'support/scrutinize_layout'

# from https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara :
include Warden::Test::Helpers
Warden.test_mode!

describe 'Creating choreographer from index page' do
  it "saves form values" do
    user = FactoryGirl.create(:user, admin: true)
    login_as(user, scope: :user)

    visit '/choreographers/new'

    fill_in "choreographer_name", with: "Bob Green"
    fill_in "choreographer_website", with: "www.bobgreen.com"
    select "Always"

    click_on "Save Choreographer"

    choreographer = Choreographer.last
    expect(choreographer.name).to eq("Bob Green")
    expect(choreographer.website).to eq("www.bobgreen.com")
    expect(choreographer.publish).to eq("always")
    scrutinize_layout(page)
  end
end
