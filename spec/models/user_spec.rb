require 'spec_helper'

RSpec.describe User, type: :model do
  it "returns all users in case-insensitive alphabetical order" do
    names = ["AAAA","BBBB","cccc","DDDD"]
    names.each {|name| FactoryGirl.create :user, name: name }
    expect(User.all.pluck(:name)).to eq ["AAAA","BBBB","cccc","DDDD"]
  end
end
