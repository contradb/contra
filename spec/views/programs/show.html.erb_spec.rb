require 'rails_helper'

RSpec.describe "programs/show", type: :view do
  before(:each) do
    @user = FactoryGirl.create(:user, name: "Roland Kevra")
    @program = FactoryGirl.build_stubbed(:program, title: "New Years Eve 2015", user: @user)
  end

  it "renders attributes" do
    render
    expect(rendered).to match(/New Years Eve 2015/)
    expect(rendered).to match(/Roland Kevra/)
  end
end
