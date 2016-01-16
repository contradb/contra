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

  it "renders dance information" do
    dance_owner   = FactoryGirl.create(:user, name: "Bob Danceownerson")
    choreographer = FactoryGirl.create(:choreographer, name: "Susan MacChoreographer")
    dance         = FactoryGirl.create(:dance, title: "Revenge of Voldemort",
                                       user: dance_owner, choreographer: choreographer)
    @program.append_new_activity(dance: dance, text: "some text too")

    render

    expect(rendered).to match("Bob Danceownerson")
    expect(rendered).to match("Susan MacChoreographer")
    expect(rendered).to match("Revenge of Voldemort")
    expect(rendered).to match("some text too")
  end
end
