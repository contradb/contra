# coding: utf-8
require 'rails_helper'
require 'support/scrutinize_layout'
require 'programs_helper'

describe 'Showing programs' do
  include ProgramsHelper
  let (:owner) {FactoryGirl.create(:user) }
  let (:user) {FactoryGirl.create(:user)}
  let (:admin) {FactoryGirl.create(:user, admin: true)}
  let (:dance_private) {FactoryGirl.create(:dance, publish: false, user: owner, title: "Hopscotch")}
  let (:dance) {FactoryGirl.create(:dance, title: "Awendigo")}
  let (:program) {FactoryGirl.create(:program, title: "New Years Eve 2015")}

  it "renders stored values" do
    program.append_new_activity(dance: dance, text: 'dancy text')
    program.append_new_activity(text: 'hambo')
    figure_txt = JSLibFigure.figure_to_unsafe_text(dance.figures.first, JSLibFigure.default_dialect)

    visit program_path(program)

    expect(page).to have_content(program.title)
    expect(page).to have_content(dance.title)
    expect(page).to have_content('dancy text')
    expect(page).to have_content(dance.start_type)
    expect(figure_txt).to match(/neighbors +balance +& +swing/)
    expect(page).to have_content(figure_txt)
    expect(page).to have_content('hambo')
  end

  it "renders an index" do
    markdown_href = "http://www.quiteapair.us/calling/acdol/dance/acd_157.html"
    program.append_new_activity(dance: dance, text: "[Hello Markdown](#{markdown_href}) by *Tom Hinds*")
    activity = program.activities.last
    visit program_path(program)
    anchor = program_path(program, anchor: activity_anchor_id(activity.index))
    expect(page).to have_link("#{dance.title} by #{dance.choreographer.name}", href: anchor)
    expect(page).to have_css('em', text: 'Tom Hinds')
    expect(page).to have_link('Hello Markdown', href: anchor) # within index
    expect(page).to have_link('Hello Markdown', href: markdown_href) # within body
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

  describe 'former view specs' do
    def setup_rang_tang(program)
      activity_text = "some activity text"
      rang_tang = FactoryGirl.create(
        :dance,
        title: "Rang Tang Contra",
        start_type: "improper",
        user: FactoryGirl.create(:user, name: "Bob Danceownerson"),
        choreographer: FactoryGirl.create(:choreographer, name: "Susan MacChoreographer"),
        figures_json: '[{"parameter_values":["neighbor rang tang right",6],"move":"custom"},{"parameter_values":["partner rang tang left",6],"move":"custom"},{"parameter_values":["neighbor rang tang right",6],"move":"custom"},{"parameter_values":["partner rang tang left",6],"move":"custom"},{"parameter_values":["neighbors",false,8],"move":"swing"},{"parameter_values":[true,270,8],"move":"circle"},{"parameter_values":["partners",false,8],"move":"swing"},{"parameter_values":["ladles",true,"across",8],"move":"chain"},{"parameter_values":["hands across",false,360,8],"move":"star"}]',
        notes: 'What are rang tangs? Rang_tang left = allemande left once along sets, gents cross over. Rang_tang right = allemande right once along sets, gents cross over.

Truly, this dance is "by unknown", according to C. A. Gray. This particular variation is called by Diane Silver
https://www.youtube.com/watch?v=jbeDG5jmKvE

')
      program.append_new_activity(dance: rang_tang, text: activity_text)
      rang_tang
    end

    def setup_box_the_gnat(program)
      dance_owner   = FactoryGirl.create(:user, name: "Kevin Gargledancer")
      choreographer = FactoryGirl.create(:choreographer, name: "Becky Hill")
      box_the_gnat  = FactoryGirl.create(:box_the_gnat_contra, user: dance_owner, choreographer: choreographer)
      program.append_new_activity(dance: box_the_gnat, text: "Dave's go-to stompy dance")
      box_the_gnat
    end

    def setup_custodance(program)
      user = FactoryGirl.create(:user, name: "Yet Another User")
      choreographer = FactoryGirl.create(:choreographer, name: "Yet Another Choreographer")
      custodance =    FactoryGirl.create(:dance,
                                         title: "Custodance",
                                         user: user,
                                         choreographer: choreographer,
                                         start_type: "improper",
                                         figures_json: '[{"parameter_values":["neighbor rang tang right",6],"move":"custom"},{"parameter_values":["gentlespoons",true,360,8],"move":"do si do"}]',
                                         notes: 'yet more dance notes')
      program.append_new_activity(dance: custodance, text: "featuring **2 new moves**!")
      custodance
    end

    it "highlights newly introduced figures as they appear in the program" do
      setup_rang_tang(program)
      setup_box_the_gnat(program)

      visit program_path(program)

      expect(page).to have_text("introduces moves: box the gnat, swat the flea, allemande, right left through")
    end

    it "translates newly introduced figure terms to substitutions as they appear in the program" do
      setup_rang_tang(program)
      setup_box_the_gnat(program)
      expect_any_instance_of(ProgramsController).to receive(:dialect).and_return(JSLibFigure.test_dialect)

      visit program_path(program)

      expect(page).to have_text("introduces moves: box the gnat, swat the flea, almond, right left through")
    end

    it "never remembers custom moves have been previously introduced" do
      setup_rang_tang(program)
      setup_box_the_gnat(program)
      setup_custodance(program)

      visit program_path(program)

      expect(page).to have_text(/introduces moves: custom, do si do/)
    end

    it "has markdown support" do
      setup_custodance(program)

      visit program_path(program)

      expect(page).to have_css('strong', text: "2 new moves")
    end
  end
end
