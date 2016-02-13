require 'rails_helper'

RSpec.describe "dances/edit", type: :view do
  before(:each) do
    @dance = assign(:dance, Dance.create!(
      :title => "Box the Gnat Contra",
      :start_type => "improper",
      :figures_json => "[{\"who\":\"neighbor\",\"move\":\"box_the_gnat\",\"beats\":8,\"balance\":true}, {\"who\":\"partner\",\"move\":\"swat_the_flea\",\"beats\":8,\"balance\":true}, {\"who\":\"neighbor\",\"move\":\"swing\",\"beats\":16,\"balance\":true}, {\"who\":\"ladles\",\"move\":\"allemande_right\",\"beats\":8,\"degrees\":540}, {\"who\":\"partner\",\"move\":\"swing\",\"beats\":8}, {\"who\":\"everybody\",\"move\":\"right_left_through\",\"beats\":8}, {\"who\":\"ladles\",\"move\":\"chain\",\"beats\":8,\"notes\":\"look for new\"}]",
      :notes => "Swat the Flea variation"
    ))
  end

  it "renders the edit dance form" do
    render

    assert_select "form[action=?][method=?]", dance_path(@dance), "post" do

      assert_select "input#dance_title[name=?]", "dance[title]"

      assert_select "textarea#dance_notes[name=?]", "dance[notes]"
    end
  end

  pending "shows the figures of an existing dance"
end
