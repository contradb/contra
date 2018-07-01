require 'rails_helper'
require 'support/scrutinize_layout'

# from https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara :
include Warden::Test::Helpers
Warden.test_mode!

describe 'Copying programs' do
  let :program {FactoryGirl.create(:program,
                                   title: "Fish Dance",
                                   dances: [:box_the_gnat_contra, :call_me].map {|sym| FactoryGirl.create(sym)},
                                   text_activities: ['waltz', 'break'])}
  let :activities {[FactoryGirl.create(:activity)]}

  before (:each) do
    login_as(FactoryGirl.create(:user))
  end

  it "copies the title" do
    visit program_path(program)
    click_link 'Copy'

    scrutinize_layout page
    expect(page).to have_selector("input[value='Fish Dance copy']")
  end

  it "copies the program"
end
