require 'rails_helper'
require 'support/scrutinize_layout'

# from https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara :
include Warden::Test::Helpers
Warden.test_mode!

describe 'Copying programs', js: true do
  let :program {FactoryGirl.create(:program,
                                   title: "Fish Dance",
                                   dances: [:box_the_gnat_contra, :call_me].map {|sym| FactoryGirl.create(sym)},
                                   text_activities: ['waltz', 'break'])}
  let :activities {[FactoryGirl.create(:activity)]}

  before (:each) do
    login_as(FactoryGirl.create(:user))
  end

  it "copies the program" do
    visit new_program_path(copy_program_id: program.id)
    expect(page).to have_selector("input[value='Fish Dance copy']")
    click_button 'Save Program'
    expect(page).to have_content('Program was successfully created.')
    copy = Program.last
    expect(copy.id).to_not eq(program.id)
    expect(copy.title).to eq("#{program.title} copy")
    expect(copy.user_id).to_not eq(program.user_id)
    changed_attributes = %w(id title user_id created_at updated_at)
    expect(copy.attributes.except(*changed_attributes)).to eq(program.attributes.except(*changed_attributes))
    expect(copy.activities.length).to eq(program.activities.length)
    copy.activities.each do |copy_activity|
      program_activity = program.activities.find_by(dance_id: copy_activity.dance_id, text: copy_activity.text.presence)
      expect(program_activity).to be_a(Activity)
    end
  end
end
