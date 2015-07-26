require 'rails_helper'

RSpec.describe "dances/edit", type: :view do
  before(:each) do
    @dance = assign(:dance, Dance.create!(
      :title => "MyString",
      :start_type => "MyString",
      :figure1 => "MyString",
      :figure2 => "MyString",
      :figure3 => "MyString",
      :figure4 => "MyString",
      :figure5 => "MyString",
      :figure6 => "MyString",
      :figure7 => "MyString",
      :figure8 => "MyString",
      :notes => "MyText"
    ))
  end

  it "renders the edit dance form" do
    render

    assert_select "form[action=?][method=?]", dance_path(@dance), "post" do

      assert_select "input#dance_title[name=?]", "dance[title]"

      assert_select "input#dance_start_type[name=?]", "dance[start_type]"

      assert_select "input#dance_figure1[name=?]", "dance[figure1]"

      assert_select "input#dance_figure2[name=?]", "dance[figure2]"

      assert_select "input#dance_figure3[name=?]", "dance[figure3]"

      assert_select "input#dance_figure4[name=?]", "dance[figure4]"

      assert_select "input#dance_figure5[name=?]", "dance[figure5]"

      assert_select "input#dance_figure6[name=?]", "dance[figure6]"

      assert_select "input#dance_figure7[name=?]", "dance[figure7]"

      assert_select "input#dance_figure8[name=?]", "dance[figure8]"

      assert_select "textarea#dance_notes[name=?]", "dance[notes]"
    end
  end
end
