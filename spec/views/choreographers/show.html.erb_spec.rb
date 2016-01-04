require 'rails_helper'

RSpec.describe "choreographers/show", type: :view do
  before(:each) do
    @choreographer = build_stubbed(:choreographer, :name => "Wombat Fugliuus")
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Wombat Fugliuus/)
  end



end
