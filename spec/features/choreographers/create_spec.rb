require 'rails_helper'
require 'spec_helper'

describe 'Creating choreographer from index page' do
  it "goes to the New Choreographer page on success" do
    visit '/choreographers'
    click_link "New Choreographer"
    # assumes logged in, but I don't know how to do that yet -dm 12-16-2015
    expect(page).to have_content("New Choreographer")
  end
end
