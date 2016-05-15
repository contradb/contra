require 'rails_helper'

RSpec.describe Choreographer, type: :model do
  it "returns all choreographers in case-insensitive alphabetical order" do
    names = ["AAAA","BBBB","cccc","DDDD"]
    names.each {|name| FactoryGirl.create :choreographer, name: name }
    expect(Choreographer.all.pluck(:name)).to eq ["AAAA","BBBB","cccc","DDDD"]
  end
end
