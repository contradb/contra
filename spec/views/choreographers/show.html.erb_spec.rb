require 'rails_helper'

RSpec.describe "choreographers/show", type: :view do
  before(:each) do
    @choreographer = build_stubbed(:choreographer, name: "Wombat Fugliuus")
    @dances = [build_stubbed(:dance, title: "Robot Roll Call")]
  end

  it "renders name" do
    render
    expect(rendered).to match(@choreographer.name)
    @dances.each do |dance|
      expect(rendered).to match(dance.title)
    end
  end
end
