require 'rails_helper'
require 'spec_helper'
require 'support/scrutinize_layout'

# from https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara :
include Warden::Test::Helpers
Warden.test_mode!


describe 'Showing programs' do
  before (:each) do
    @user1 = FactoryGirl.create(:user)
    @user2 = FactoryGirl.create(:user)
    login_as(@user1, :scope => :user)
    @program = FactoryGirl.create(:program, user: @user1, 
                                  title: "Fleur De Lis Fling Friday")
  end

  after (:each) do
    visit "/programs/#{@program.id}"

    scrutinize_layout page
    expect(page).to have_css("h1", text: "Fleur De Lis Fling Friday")
  end

  it "renders logged in as the same user" do end
  it "renders logged out"                 do logout(:user) end
  it "renders logged in as a different user" do
    logout(:user)
    login_as(@user2, :scope => :user)
  end

  pending "shows the activities of a dance"
end
