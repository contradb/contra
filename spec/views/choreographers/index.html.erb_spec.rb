require 'rails_helper'

RSpec.describe "choreographers/index", type: :view do
  before(:each) do
    assign(:choreographers, [
      Choreographer.create!(
        :name => "Name"
      ),
      Choreographer.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of choreographers" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
