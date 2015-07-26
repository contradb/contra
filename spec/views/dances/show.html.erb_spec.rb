require 'rails_helper'

RSpec.describe "dances/show", type: :view do
  before(:each) do
    @dance = assign(:dance, Dance.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Start Type/)
    expect(rendered).to match(/Figure1/)
    expect(rendered).to match(/Figure2/)
    expect(rendered).to match(/Figure3/)
    expect(rendered).to match(/Figure4/)
    expect(rendered).to match(/Figure5/)
    expect(rendered).to match(/Figure6/)
    expect(rendered).to match(/Figure7/)
    expect(rendered).to match(/Figure8/)
    expect(rendered).to match(/MyText/)
  end
end
