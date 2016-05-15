require 'rails_helper'

RSpec.describe Dance, type: :model do
  it "returns dances in case-insensitive alphabetical order" do
    user = FactoryGirl.create :user, name: "Eugene User"
    titles = ["AAAA","BBBB","cccc","DDDD"]
    titles.each {|title| FactoryGirl.create :dance, user: user, title: title }
    expect(Dance.all.pluck(:title)).to eq ["AAAA","BBBB","cccc","DDDD"]
  end
end
