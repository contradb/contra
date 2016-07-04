require 'rails_helper'
require 'login_helper'
require 'support/scrutinize_layout'


describe 'Creating dances' do
  it "creates a new dance with non-javascript data", js: true do
    with_login do
      visit '/dances/new'
      expect(page.text).to include 'There\'s a lot of ink spilled over "gentlemen" versus "men" versus "leads".'
      fill_in "dance_title", with: "Call Me"
      fill_in "dance[choreographer_name]", with: "Cary Ravitz"
      fill_in "dance[start_type]", with: "improper"
      click_button "Save Dance"
      
      expect(page).to have_css("h1", text: "Call Me")
      expect(page).to have_content("Cary Ravitz")
      expect(page).to have_content("improper")
    end
  end

  pending "creates a new dance with some interesting figures"

  pending "tests choreographer auto-complete"

end
