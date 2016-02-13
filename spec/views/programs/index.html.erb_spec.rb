require 'rails_helper'

RSpec.describe "programs/index", type: :view do
  before(:each) do
    @programs = 
      [FactoryGirl.build_stubbed(:program, title: "Open Calling Night"),
       FactoryGirl.build_stubbed(:program, title: "Monday Night Dance")]
  end

  it "renders a list of programs" do
    render
    expect(rendered).to match(/Open Calling Night/)
    expect(rendered).to match(/Monday Night Dance/)
  end
end
