require 'rails_helper'

RSpec.describe "choreographers/edit", type: :view do
  before(:each) do
    @choreographer = assign(:choreographer, Choreographer.create!(
      :name => "MyString"
    ))
  end

  it "renders the edit choreographer form" do
    render

    assert_select "form[action=?][method=?]", choreographer_path(@choreographer), "post" do

      assert_select "input#choreographer_name[name=?]", "choreographer[name]"
    end
  end
end
