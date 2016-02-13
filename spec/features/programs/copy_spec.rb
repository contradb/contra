require 'rails_helper'
require 'spec_helper'
require 'support/scrutinize_layout'

# from https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara :
include Warden::Test::Helpers
Warden.test_mode!

describe 'Copying programs' do
  before (:each) do
    @user = FactoryGirl.create(:user)
    login_as(@user, :scope => :user)
    @program = FactoryGirl.create(:program, user: @user, title: "Fish Dance")
  end

  it "copies the title" do
    visit "/programs/#{@program.id}"
    click_link 'Copy'

    scrutinize_layout page
    expect(page).to have_selector("input[value='Fish Dance copy']")
  end

  pending "copies the activities"
end
