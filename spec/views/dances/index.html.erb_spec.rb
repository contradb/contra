require 'rails_helper'

RSpec.describe "dances/index", type: :view do
  before(:each) do
    assign(:dances, [
      Dance.create!(
        :title => "Title",
        :start_type => "Start Type",
        :figure1 => "Figure1",
        :figure2 => "Figure2",
        :figure3 => "Figure3",
        :figure4 => "Figure4",
        :figure5 => "Figure5",
        :figure6 => "Figure6",
        :figure7 => "Figure7",
        :figure8 => "Figure8",
        :notes => "MyText"
      ),
      Dance.create!(
        :title => "Title",
        :start_type => "Start Type",
        :figure1 => "Figure1",
        :figure2 => "Figure2",
        :figure3 => "Figure3",
        :figure4 => "Figure4",
        :figure5 => "Figure5",
        :figure6 => "Figure6",
        :figure7 => "Figure7",
        :figure8 => "Figure8",
        :notes => "MyText"
      )
    ])
  end

  it "renders a list of dances" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Start Type".to_s, :count => 2
    assert_select "tr>td", :text => "Figure1".to_s, :count => 2
    assert_select "tr>td", :text => "Figure2".to_s, :count => 2
    assert_select "tr>td", :text => "Figure3".to_s, :count => 2
    assert_select "tr>td", :text => "Figure4".to_s, :count => 2
    assert_select "tr>td", :text => "Figure5".to_s, :count => 2
    assert_select "tr>td", :text => "Figure6".to_s, :count => 2
    assert_select "tr>td", :text => "Figure7".to_s, :count => 2
    assert_select "tr>td", :text => "Figure8".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
