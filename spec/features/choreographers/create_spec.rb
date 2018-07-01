require 'rails_helper'

describe 'Creating choreographer from index page' do
  it "saves form values" do
    with_login(admin: true) do
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
end
