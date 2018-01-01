require 'rails_helper'
require 'support/scrutinize_layout'

# from https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara :
include Warden::Test::Helpers
Warden.test_mode!


describe 'Showing programs' do
  let (:owner) {FactoryGirl.create(:user) }
  let (:user) {FactoryGirl.create(:user)}
  let (:admin) {FactoryGirl.create(:user, admin: true)}
  let (:dance_private) {FactoryGirl.create(:dance, publish: false, user: owner, title: "Hopscotch")}
  let (:dance) {FactoryGirl.create(:dance, title: "Awendigo")}
  let (:program) {FactoryGirl.create(:program)}
  
  it "renders stored values" do
    program.append_new_activity(dance: dance)
    program.append_new_activity(text: 'hambo')
    figure_html = JSLibFigure.figureToString(dance.figures.first, JSLibFigure.stub_prefs)

    visit program_path(program)

    expect(page).to have_content(program.title)
    expect(page).to have_content(dance.title)
    expect(figure_html).to match(/neighbors +balance +& +swing/)
    expect(page).to have_content(figure_html)
    expect(page).to have_content('hambo')
  end

  describe 'privacy' do
    let (:figure_html) {JSLibFigure.figureToString(dance_private.figures.first, JSLibFigure.stub_prefs)}
    before(:each) {program.append_new_activity(dance: dance_private)}

    it "does not display figures of a private dance" do
      visit program_path(program)
      expect(page).to_not have_content(figure_html)
      expect(page).to have_content('This dance is not published')
    end

    it "does display figures of a private dance if owner" do
      login_as(owner, scope: :user)
      visit program_path(program)
      expect(page).to have_content(figure_html)
      expect(page).to_not have_content('This dance is not published')
    end

    it "does not display figures of a private dance if logged in as some random person" do
      login_as(user, scope: :user)
      visit program_path(program)
      expect(page).to_not have_content(figure_html)
      expect(page).to have_content('This dance is not published')
    end

    it "does display figures of a private dance if admin" do
      login_as(admin, scope: :user)
      visit program_path(program)
      expect(page).to have_content(figure_html)
      expect(page).to_not have_content('This dance is not published')
    end
  end
end
