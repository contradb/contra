require 'rails_helper'

RSpec.describe "programs/show", type: :view do
  before(:each) do
    @program = assign(:program, FactoryGirl.create(:program, title: "New Years Eve 2015"))
    @program.append_new_activity(text: "Dosido Agogo")
    @program.append_new_activity(text: "Bubble and Squeak")
  end

  it "renders" do
    render
    expect(rendered).to match(/New Years Eve 2015/)
    expect(rendered).to match(@program.user.name)
    expect(rendered).to match("Dosido Agogo")
    expect(rendered).to match("Bubble and Squeak")
  end

  def setup_rang_tang ()
    activity_text = "some activity text"
    rang_tang = FactoryGirl.create(
      :dance,
      title: "Rang Tang Contra",
      start_type: "improper",
      user: FactoryGirl.create(:user, name: "Bob Danceownerson"),
      choreographer: FactoryGirl.create(:choreographer, name: "Susan MacChoreographer"),
      figures_json: '[{"parameter_values":["neighbor rang tang right",6],"move":"custom"},{"parameter_values":["partner rang tang left",6],"move":"custom"},{"parameter_values":["neighbor rang tang right",6],"move":"custom"},{"parameter_values":["partner rang tang left",6],"move":"custom"},{"parameter_values":["neighbors",false,8],"move":"swing"},{"parameter_values":[true,270,8],"move":"circle"},{"parameter_values":["partners",false,8],"move":"swing"},{"parameter_values":["ladles",8],"move":"chain"},{"parameter_values":[false,true,360,8],"move":"star"}]',
      notes: 'What are rang tangs? Rang_tang left = allemande left once along sets, gents cross over. Rang_tang right = allemande right once along sets, gents cross over. 

Truly, this dance is "by unknown", according to C. A. Gray. This particular variation is called by Diane Silver
https://www.youtube.com/watch?v=jbeDG5jmKvE

')
    @program.append_new_activity(dance: rang_tang, text: activity_text)
    rang_tang
  end

  def setup_box_the_gnat ()
    dance_owner   = FactoryGirl.create(:user, name: "Kevin Gargledancer")
    choreographer = FactoryGirl.create(:choreographer, name: "Becky Hill")
    box_the_gnat  = FactoryGirl.create(:box_the_gnat_contra, user: dance_owner, choreographer: choreographer)
    @program.append_new_activity(dance: box_the_gnat, text: "Dave's go-to stompy dance")
    box_the_gnat
  end

  def setup_custodance ()
    user = FactoryGirl.create(:user, name: "Yet Another User")
    choreographer = FactoryGirl.create(:choreographer, name: "Yet Another Choreographer")
    custodance =    FactoryGirl.create(:dance,
                                       title: "Custodance",
                                       user: user,
                                       choreographer: choreographer,
                                       start_type: "improper",
                                       figures_json: '[{"parameter_values":["neighbor rang tang right",6],"move":"custom"},{"parameter_values":["gentlespoons",true,360,8],"move":"do si do"}]',
                                       notes: 'yet more dance notes')
    @program.append_new_activity(dance: custodance, text: "featuring **2 new moves**!")
    custodance
  end


  it "renders dance information" do
    dance = setup_rang_tang

    render

    expect(rendered).to_not match(dance.user.name)
    expect(rendered).to match(dance.choreographer.name)
    expect(rendered).to match("Rang Tang Contra")
    expect(rendered).to match("some activity text")
    expect(rendered).to match("improper")
  end

  it "highlights newly introduced figures as they appear in the program" do
    setup_rang_tang
    setup_box_the_gnat

    render

    expect(rendered).to match("introduces moves: box the gnat, swat the flea, allemande, right left through")
  end

  it "never remembers custom moves have been previously introduced" do
    setup_rang_tang
    setup_box_the_gnat
    setup_custodance

    render

    expect(rendered).to match(/introduces moves: custom, do si do/)
  end

  it "has markdown support" do
    setup_custodance

    render

    expect(rendered).to match("featuring <strong>2 new moves</strong>!")
  end
end


