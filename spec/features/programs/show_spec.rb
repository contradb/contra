# coding: utf-8
require 'rails_helper'
require 'support/scrutinize_layout'

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
    figure_txt = JSLibFigure.figure_to_unsafe_text(dance.figures.first, JSLibFigure.default_dialect)

    visit program_path(program)

    expect(page).to have_content(program.title)
    expect(page).to have_content(dance.title)
    expect(figure_txt).to match(/neighbors +balance +& +swing/)
    expect(page).to have_content(figure_txt)
    expect(page).to have_content('hambo')
  end

  describe 'privacy' do
    let (:figure_txt) {JSLibFigure.figure_to_unsafe_text(dance_private.figures.first, JSLibFigure.default_dialect)}
    before(:each) {program.append_new_activity(dance: dance_private)}

    it "does not display figures of a private dance" do
      visit program_path(program)
      expect(page).to_not have_content(figure_txt)
      expect(page).to have_content('This dance is not published')
    end

    it "does display figures of a private dance if owner" do
      with_login(user: owner) do
        visit program_path(program)
        expect(page).to have_content(figure_txt)
        expect(page).to_not have_content('This dance is not published')
      end
    end

    it "does not display figures of a private dance if logged in as some random person" do
      with_login(user: user) do
        visit program_path(program)
        expect(page).to_not have_content(figure_txt)
        expect(page).to have_content('This dance is not published')
      end
    end

    it "does display figures of a private dance if admin" do
      with_login(user: admin) do
        visit program_path(program)
        expect(page).to have_content(figure_txt)
        expect(page).to_not have_content('This dance is not published')
      end
    end
  end
end
