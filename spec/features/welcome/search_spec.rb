# coding: utf-8

require 'rails_helper'

describe 'Search page', js: true do
  it "works" do
    dances = 12.times.map {|i| FactoryGirl.create(:dance, title: "Dance #{i}.")}
    visit(s_path)
    dances.each_with_index do |dance, i|
      to_probably = i < 10 ? :to : :to_not
      expect(page).send to_probably, have_link(dance.title, href: dance_path(dance))
      expect(page).send to_probably, have_link(dance.choreographer.name, href: choreographer_path(dance.choreographer_id))
    end
  end
end
