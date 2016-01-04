require 'rails_helper'

RSpec.describe "dances/new", type: :view do
  before(:each) do
    @choreographer = FactoryGirl.create(:choreographer)
    @dance = build_stubbed(:dance, choreographer: @choreographer, title: '', start_type: '', notes: '')
  end


  it "renders new dance form" do
    render

    expect(rendered).to match(Regexp.new Regexp.escape @dance.title)
    expect(rendered).to match(Regexp.new Regexp.escape @dance.choreographer.name)
    assert_select "form[method=?]", "post" do
      assert_select "input#dance_title[name=?]", "dance[title]"
      # don't test choreographer because it's a select box
      assert_select "input#dance_start_type[name=?]", "dance[start_type]"
      # don't test figures because it's javascript-generated. 
      assert_select "textarea#dance_notes[name=?]", "dance[notes]"
    end
  end
end
