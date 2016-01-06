require 'rails_helper'

RSpec.describe "programs/edit", type: :view do
  before(:each) do
    @program = FactoryGirl.build_stubbed(:program)
  end

  it "renders the edit program form" do
    render
    expect(response).to have_field("program[title]")
  end
end
