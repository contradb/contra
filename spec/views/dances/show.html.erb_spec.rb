# -*- coding: utf-8 -*-

require 'rails_helper'




RSpec.describe "dances/show", type: :view do
  before(:each) do
    @dance = assign(:dance, Dance.create!(
      :title => "Clever Pun",
      :start_type => "Complicated Formation",
      :choreographer => FactoryGirl.build_stubbed(:choreographer, name: "Becky Hill"),
      :user => FactoryGirl.build_stubbed(:user),
      :figures_json => '[{"who":"neighbor","move":"box_the_gnat","beats":8,"balance":true}, 
                         {"who":"partner","move":"swat_the_flea","beats":8,"balance":true}, 
                         {"who":"neighbor","move":"swing","beats":16,"balance":true}, 
                         {"who":"ladles","move":"allemande_right","beats":8,"degrees":540}, 
                         {"who":"partner","move":"swing","beats":8}, 
                         {"who":"everybody","move":"right_left_through","beats":8}, 
                         {"who":"ladles","move":"chain","beats":8,"notes":"look for new"}]',
      :notes => "My Note Text"
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
    expect(rendered).to match(regexpify 'neighbor balance + box_the_gnat')
    expect(rendered).to match(regexpify 'partner balance + swat_the_flea')
    expect(rendered).to match(regexpify 'neighbor balance + swing for 16')
    expect(rendered).to match(regexpify 'ladles allemande_right 1½')
    expect(rendered).to match(regexpify 'partner swing')
    expect(rendered).to match(regexpify 'right_left_through')
    expect(rendered).to match(regexpify 'ladles chain look for new')
    # notes
    expect(rendered).to match(/My Note Text/)
  end

end
