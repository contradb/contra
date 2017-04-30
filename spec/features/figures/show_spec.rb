
require 'rails_helper'

describe 'figures show' do
  let (:box) { FactoryGirl.create(:box_the_gnat_contra) }
  let (:call) { FactoryGirl.create(:call_me) }

  it 'usage tab' do
    box
    visit figure_path('swing')
    expect(page).to have_css("h1", text: 'Swing')
    expect(page).to have_content('related figures: gyre meltdown')
    expect(page).to have_content('formal parameters: who, bal, beats')
    # 'examples' table should have two swings for Box the Gnat
    expect(page).to have_content("#{box.title} neighbors balance & swing partners swing")
  end

  it 'without tab' do
    box
    call
    visit figure_path('star')
    expect(page).to have_css("#without", text: box.title)
    expect(page).to_not have_css("#without", text: call.title)
  end

  it 'with-figure tab' do
    box
    call
    visit figure_path('star')
    call.moves.each do |move|
      expect(page).to have_css("#with-figure", text: "#{move} #{call.title}") unless 'star' == move
    end
    expect(page).to_not have_css("#with-figure", text: box.title)
  end

  it 'beside-figure tab' do
    box
    visit figure_path('swing')
    expect(page).to have_css("#moves-preceding", text: "swat the flea #{box.title}")
    expect(page).to have_css("#moves-preceding", text: "allemande #{box.title}")
    expect(page).to_not have_css("#moves-preceding", text: "right left through #{box.title}")
    expect(page).to have_css("#moves-following", text: "allemande #{box.title}")
    expect(page).to have_css("#moves-following", text: "right left through #{box.title}")
    expect(page).to_not have_css("#moves-following", text: "swat the flea #{box.title}")
  end
end
