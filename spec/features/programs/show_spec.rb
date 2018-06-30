# coding: utf-8
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
    figure_html = JSLibFigure.figure_to_html(dance.figures.first, JSLibFigure.default_dialect)

    visit program_path(program)

    expect(page).to have_content(program.title)
    expect(page).to have_content(dance.title)
    expect(figure_html).to match(/neighbors +balance +&amp; +swing/)
    expect(page).to have_content(figure_html.gsub('&amp;', '&'))
    expect(page).to have_content('hambo')
  end


  # This works, but was moved to a view spec and a controller spec:
  # it "applies dialect" do
  #   login_as(user, scope: :user)
  #   allow_any_instance_of(User).to receive(:dialect).and_return(JSLibFigure.test_dialect)
  #   program.append_new_activity(dance: FactoryGirl.create(:box_the_gnat_contra))
  #   visit program_path(program)
  #   expect(page).to have_content('ravens almond right 1½')
  # end

  describe 'privacy' do
    let (:figure_html) {JSLibFigure.figure_to_html(dance_private.figures.first, JSLibFigure.default_dialect)}
    let (:figure_html_amp) {figure_html.gsub('&amp;', '&')}
    before(:each) {program.append_new_activity(dance: dance_private)}

    it "does not display figures of a private dance" do
      visit program_path(program)
      expect(page).to_not have_content(figure_html)
      expect(page).to have_content('This dance is not published')
    end

    it "does display figures of a private dance if owner" do
      login_as(owner, scope: :user)
      visit program_path(program)
      expect(page).to have_content(figure_html_amp)
      expect(page).to_not have_content('This dance is not published')
    end

    it "does not display figures of a private dance if logged in as some random person" do
      login_as(user, scope: :user)
      visit program_path(program)
      expect(page).to_not have_content(figure_html_amp)
      expect(page).to have_content('This dance is not published')
    end

    it "does display figures of a private dance if admin" do
      login_as(admin, scope: :user)
      visit program_path(program)
      expect(page).to have_content(figure_html_amp)
      expect(page).to_not have_content('This dance is not published')
    end
  end
end
