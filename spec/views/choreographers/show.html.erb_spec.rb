require 'rails_helper'

RSpec.describe "choreographers/show", type: :view do
  before(:each) do
    @choreographer = assign(:choreographer, Choreographer.create!(
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
