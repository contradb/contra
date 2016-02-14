require 'rails_helper'

RSpec.describe "programs/show", type: :view do
  before(:each) do
    @user = FactoryGirl.create(:user, name: "Roland Kevra")
    @program = FactoryGirl.create(:program, title: "New Years Eve 2015", user: @user)
    @program.append_new_activity(text: "Dosido Agogo")
    @program.append_new_activity(text: "Bubble and Squeak")
  end

  it "renders" do
    render
    expect(rendered).to match(/New Years Eve 2015/)
    expect(rendered).to match(/Roland Kevra/)
    expect(rendered).to match("Dosido Agogo")
    expect(rendered).to match("Bubble and Squeak")
  end

  def setup_rang_tang ()
    user = FactoryGirl.create(:user, name: "Bob Danceownerson")
    choreographer = FactoryGirl.create(:choreographer, name: "Susan MacChoreographer")
    activity_text = "some activity text"
    rang_tang     = FactoryGirl.create(:dance,
                                       title: "Rang Tang Contra",
                                       user: user,
                                       choreographer: choreographer,
                                       start_type: "improper",
                                       figures_json: '[{"formation":"square","who":"neighbor","beats":6,"move":"custom","notes":"rang_tang left"},{"formation":"square","who":"partner","beats":6,"move":"custom","notes":"rang_tang right"},{"formation":"square","who":"neighbor","beats":6,"notes":"rang_tang left","move":"custom"},{"formation":"square","who":"partner","beats":6,"notes":"rang_tang right","move":"custom"},{"formation":"square","who":"neighbor","beats":8,"move":"swing"},{"formation":"square","who":"everybody","beats":8,"move":"circle_left","degrees":270},{"formation":"square","who":"partner","beats":8,"move":"swing"},{"formation":"square","who":"ladles","beats":8,"move":"chain"},{"formation":"square","who":"everybody","beats":8,"move":"star_left","degrees":360,"notes":"to new neighbor"}]',
                                       notes: 'What are rang tangs? Rang_tang left = allemande left once along sets, gents cross over. Rang_tang right = allemande right once along sets, gents cross over. 

Truly, this dance is "by unknown", according to C. A. Gray. This particular variation is called by Diane Silver
https://www.youtube.com/watch?v=jbeDG5jmKvE

')
    @program.append_new_activity(dance: rang_tang, text: activity_text)
  end

  def setup_box_the_gnat ()
    dance_owner   = FactoryGirl.create(:user, name: "Kevin Gargledancer")
    choreographer = FactoryGirl.create(:choreographer, name: "Becky Hill")
    box_the_gnat  = FactoryGirl.create(:dance,
                                       title: "Box the Gnat Contra",
                                       user: dance_owner,
                                       choreographer: choreographer,
                                       start_type: "improper",
                                       figures_json: '[{"formation":"square","who":"neighbor","beats":8,"move":"box_the_gnat","balance":true},{"formation":"square","who":"partner","beats":8,"move":"swat_the_flea","balance":true},{"formation":"square","who":"neighbor","beats":16,"move":"swing","balance":true},{"formation":"square","who":"ladles","beats":8,"move":"allemande_right","degrees":540},{"formation":"square","who":"partner","beats":8,"move":"swing"},{"formation":"square","who":"everybody","beats":8,"move":"right_left_through"},{"formation":"square","who":"ladles","beats":8,"move":"chain","notes":"to new neighbor"}]')
    @program.append_new_activity(dance: box_the_gnat, text: "Dave's go-to stompy dance")
  end

  def setup_custodance ()
    user = FactoryGirl.create(:user, name: "Yet Another User")
    choreographer = FactoryGirl.create(:choreographer, name: "Yet Another Choreographer")
    custodance =    FactoryGirl.create(:dance,
                                       title: "Custodance",
                                       user: user,
                                       choreographer: choreographer,
                                       start_type: "improper",
                                       figures_json: '[{"who":"neighbor","beats":8,"move":"custom","notes":"rang_tang left"},{"who":"neighbor","beats":8,"move":"mad_robin"}]',
                                       notes: 'yet more dance notes')
    @program.append_new_activity(dance: custodance, text: "featuring **2 new moves**!")
  end


  it "renders dance information" do
    setup_rang_tang

    render

    expect(rendered).to_not match("Bob Danceownerson")
    expect(rendered).to match("Susan MacChoreographer")
    expect(rendered).to match("Rang Tang Contra")
    expect(rendered).to match("some activity text")
    expect(rendered).to match("improper")
  end

  it "highlights newly introduced figures as they appear in the program" do
    setup_rang_tang
    setup_box_the_gnat

    render

    expect(rendered).to match("introduces moves: box_the_gnat, swat_the_flea, allemande_right, right_left_through")
  end

  it "never remembers custom moves have been previously introduced" do
    setup_rang_tang
    setup_box_the_gnat
    setup_custodance

    render

    # If you're reading this it's because this has broken, and that's
    # because I wrote it brittle as heck. Sorry.
    # I want to check that new moves of the second occurrence of rang tang contra
    # have only one 'new move', that is "custom"
    expect(rendered).to match(/introduces moves: custom, mad_robin/)
  end

  it "has markdown support" do
    setup_custodance

    render

    expect(rendered).to match("featuring <strong>2 new moves</strong>!")
  end
end


