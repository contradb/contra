# -*- coding: utf-8 -*-

require 'rails_helper'




RSpec.describe "dances/show", type: :view do
  before(:each) do
    @dance = assign(:dance, FactoryGirl.build_stubbed(:dance,
      :title => "Clever Pun",
      :start_type => "Complicated Formation",
      :choreographer => FactoryGirl.build_stubbed(:choreographer, name: "Becky Hill"),
      :user => FactoryGirl.build_stubbed(:user),
      :figures_json => '[{"parameter_values":["partners",true,16],"move":"balance and swing", "note":"https://github.com/vmg/redcarpet **markdown**"}]',
      :notes => "My Note Text www.yahoo.com blah blah **bold** blah"
    ))
  end

  # was false positive bugs because there were double-spaces in html
  # content but html renders any number of spaces as one space.
  def regexpify(s) Regexp.new Regexp.escape(s).gsub(/ +/,' +') end

  it "renders attributes" do
    render
    expect(rendered).to match(/Clever Pun/)
    expect(rendered).to match(/Complicated Formation/)
    expect(rendered).to match(/Becky Hill/)
    # figures
    expect(rendered).to match(regexpify 'partners balance &amp; swing')
    # notes
    expect(rendered).to match(/My Note Text/)
  end

  it "supports Markdown dance notes" do
    render
    expect(rendered).to have_link('www.yahoo.com')
    expect(rendered).to match('<strong>bold</strong>')
  end

  it "supports Markdown figure notes" do
    render
    expect(rendered).to have_link('https://github.com/vmg/redcarpet')
    expect(rendered).to match('<strong>markdown</strong>')
  end

end
