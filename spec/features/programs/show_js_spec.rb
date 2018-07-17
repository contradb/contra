# coding: utf-8
require 'rails_helper'
require 'support/scrutinize_layout'

describe 'Showing programs', js: true do
  let (:dance) {FactoryGirl.create(:dance, preamble: 'mousetrap allemande')}
  let (:program) {FactoryGirl.create(:program)}
  
  it "renders stored values" do
    program.append_new_activity(dance: dance)
    expect(JSLibFigure).to receive(:default_dialect).at_least(:once).and_return(JSLibFigure.test_dialect)
    visit program_path(program)
    expect(page).to have_css('.no-lingo-lines u', text: 'almond')
    find('label', text: 'Clean').click
    expect(page).to_not have_css('.no-lingo-lines u', text: 'almond')
    expect(page).to have_text('mousetrap almond')
    find('label', text: 'Validate').click
    expect(page).to have_css('.no-lingo-lines u', text: 'almond')
  end
end
