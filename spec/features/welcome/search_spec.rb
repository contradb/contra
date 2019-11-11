# coding: utf-8

require 'rails_helper'

describe 'Search page', js: true do
  it "works" do
    dances = 12.times.map {|i| FactoryGirl.create(:dance, title: "Dance #{i}.")}
    visit(s_path)
    dances.each_with_index do |dance, i|
      if i < 10
        expect(page).to have_text(dance.title)
      else
        expect(page).to_not have_text(dance.title)
      end
    end
  end
end
