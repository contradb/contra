require 'rails_helper'

RSpec.describe "choreographers/new", type: :view do
  before(:each) do
    assign(:choreographer, Choreographer.new(
      :name => "MyString"
    ))
  end

  it "renders new choreographer form" do
    render

    assert_select "form[action=?][method=?]", choreographers_path, "post" do

      assert_select "input#choreographer_name[name=?]", "choreographer[name]"
    end
  end
end
