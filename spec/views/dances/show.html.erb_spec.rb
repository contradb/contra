# -*- coding: utf-8 -*-

require 'rails_helper'

RSpec.describe "dances/show", type: :view do
  let (:dance) {
    FactoryGirl.build(:dance,
                      :title => "Clever Pun",
                      :start_type => "Complicated Formation",
                      :choreographer => FactoryGirl.build_stubbed(:choreographer, name: "Becky Hill"),
                      :user => FactoryGirl.build_stubbed(:user),
                      :preamble => "Some Premable Text www.slashdot.org mumble mumble _italic_ mumble preamble gyre ladles preamble",
                      :figures_json => '[{"parameter_values":["partners","balance",16],"move":"swing", "note":"the quick brown fox <script>alert(\'no dialog pops up\');</script>"}, {"parameter_values":["ladles",true,540,8],"move":"allemande","note":"figure note gyre gentlespoons allemande figure note"}]',

                      :notes => "My Note Text www.yahoo.com blah blah **bold** blah notes gyre ladles notes",
                      :hook => 'hook allemande do si do hook'
                     )}
  before(:each) do
    assign(:dance, dance)
    assign(:dialect, JSLibFigure.default_dialect)
    assign(:tags, [:validated].map {|factory_name| FactoryGirl.build(:tag, factory_name)})
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
    expect(rendered).to have_content(regexpify 'partners balance & swing')
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
    dance
    render
    expect(rendered).to have_content('the quick brown fox')
  end

  it 'figure notes do not pass js injection attacks' do
    render
    expect(rendered).to have_content("<script>alert('no dialog pops up');</script>")
    expect(rendered).to_not have_content("undefined");
  end

  describe 'dialect' do
    before(:each) do
      assign(:dialect, JSLibFigure.test_dialect)
      render
    end

    it 'figures' do
      expect(rendered).to_not have_content('ladles allemande right 1½')
      expect(rendered).to have_content('ravens almond right 1½')
    end

    it 'figure notes' do
      note = dance.figures[1]['note']
      expect(note).to eq('figure note gyre gentlespoons allemande figure note')
      expect(rendered).to have_content('figure note darcy larks almond figure note')
      expect(rendered).to_not have_content(note)
    end

    it 'hook' do
      expect(dance.hook).to eq('hook allemande do si do hook')
      expect(rendered).to have_content('hook almond do si do hook')
      expect(rendered).to_not have_content(dance.hook)
    end

    it 'preamble' do
      preamble = 'preamble gyre ladles preamble'
      expect(dance.preamble).to include(preamble)
      expect(rendered).to have_content('preamble darcy ravens preamble')
      expect(rendered).to_not have_content(preamble)
    end


    it 'dance notes' do
      note = 'notes gyre ladles notes'
      expect(dance.notes).to include(note)
      expect(rendered).to have_content('notes darcy ravens notes')
      expect(rendered).to_not have_content(note)
    end
  end
end
