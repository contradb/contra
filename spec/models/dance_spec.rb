require 'rails_helper'

RSpec.describe Dance, type: :model do
  it "'alphabetical' scope returns dances in case-insensitive alphabetical order" do
    user = FactoryGirl.create :user, name: "Eugene User"
    titles = ["AAAA","DDDD","cccc","BBBB"]
    titles.each {|title| FactoryGirl.create :dance, user: user, title: title }
    expect(Dance.alphabetical.pluck(:title)).to eq ["AAAA","BBBB","cccc","DDDD"]
  end
  describe "'published_for' scope" do
    it "if not passed a user just returns published dances"
    it "if passed a user, only returns published dances or dances of that user"
  end
end
