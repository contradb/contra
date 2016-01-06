require 'rails_helper'

RSpec.describe "choreographers/index", type: :view do
  before(:each) do
    @choreographers = 
      [FactoryGirl.build_stubbed(:choreographer, name: "name1"),
       FactoryGirl.build_stubbed(:choreographer, name: "name2")]
  end

  it "renders a list of choreographers" do
    render
    expect(rendered).to match(/name1/)
    expect(rendered).to match(/name2/)
  end
end
