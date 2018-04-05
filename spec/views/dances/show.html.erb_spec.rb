# -*- coding: utf-8 -*-

require 'rails_helper'




RSpec.describe "dances/show", type: :view do
  before(:each) do
    assign(:dance, FactoryGirl.build_stubbed(:dance,
      :title => "Clever Pun",
      :start_type => "Complicated Formation",
      :choreographer => FactoryGirl.build_stubbed(:choreographer, name: "Becky Hill"),
      :user => FactoryGirl.build_stubbed(:user),
      :preamble => "Some Premable Text www.slashdot.org mumble mumble _italic_ mumble",
      :figures_json => '[{"parameter_values":["partners","balance",16],"move":"swing", "note":"the quick brown fox <script>alert(\'no dialog pops up\');</script>"}, {"parameter_values":["ladles",true,540,8],"move":"allemande"}]',
      :notes => "My Note Text www.yahoo.com blah blah **bold** blah"
                                            ))
    assign(:dialect, JSLibFigure.default_dialect)
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

  it "supports Markdown in preamble and notes" do
    render
    expect(rendered).to have_link('www.slashdot.org')
    expect(rendered).to match('<em>italic</em>')
    expect(rendered).to have_link('www.yahoo.com')
    expect(rendered).to match('<strong>bold</strong>')
  end

  it "supports plain text figure notes" do
    render
    expect(rendered).to have_content('the quick brown fox')
  end

  it 'figure notes do not pass js injection attacks' do
    render
    expect(rendered).to have_content("<script>alert('no dialog pops up');</script>")
  end

  it 'renders dialect' do
    assign(:dialect, JSLibFigure.test_dialect)
    render
    expect(rendered).to_not have_content('ladles allemande right 1½')
    expect(rendered).to have_content('ravens almond right 1½')
  end
end
