require 'rails_helper'

RSpec.describe "dances/edit", type: :view do
  before(:each) do
    @dance = assign(:dance, FactoryGirl.build_stubbed(:box_the_gnat_contra))
  end

  it "renders the edit dance form" do
    render

    assert_select "form[action=?][method=?]", dance_path(@dance), "post" do

      assert_select "input#dance_title[name=?]", "dance[title]"

      assert_select "textarea#dance_notes[name=?]", "dance[notes]"
    end
  end
end
