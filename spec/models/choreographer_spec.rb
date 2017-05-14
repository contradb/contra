require 'rails_helper'

describe Choreographer do
  it "returns all choreographers in case-insensitive alphabetical order" do
    names = ["AAAA","BBBB","cccc","DDDD"]
    names.each {|name| FactoryGirl.create :choreographer, name: name }
    expect(Choreographer.all.pluck(:name)).to eq ["AAAA","BBBB","cccc","DDDD"]
  end

  context "website_text" do
    it "drops 'http://'" do
      website = "http://www.foo.com"
      choreographer = FactoryGirl.build_stubbed(:choreographer, website: String.new(website))
      expect(choreographer.website_text).to eq("www.foo.com")
      expect(choreographer.website).to eq(website)
    end
    it "drops 'https://'" do
      website = "https://www.foo.com"
      choreographer = FactoryGirl.build_stubbed(:choreographer, website: String.new(website))
      expect(choreographer.website_text).to eq("www.foo.com")
      expect(choreographer.website).to eq(website)
    end
    it "passes 'www.foo.com' intact" do
      website = "www.foo.com"
      choreographer = FactoryGirl.build_stubbed(:choreographer, website: String.new(website))
      expect(choreographer.website_text).to eq("www.foo.com")
      expect(choreographer.website).to eq(website)
    end
  end
  context "website_url" do
    it "passes 'http://www.foo.com'" do
      website = "http://www.foo.com"
      choreographer = FactoryGirl.build_stubbed(:choreographer, website: String.new(website))
      expect(choreographer.website_url).to eq(website)
    end
    it "passes 'https://www.foo.com'" do
      website = "https://www.foo.com"
      choreographer = FactoryGirl.build_stubbed(:choreographer, website: String.new(website))
      expect(choreographer.website_url).to eq(website)
    end
    it "adds 'http://' to 'www.foo.com'" do
      website = "www.foo.com"
      choreographer = FactoryGirl.build_stubbed(:choreographer, website: String.new(website))
      expect(choreographer.website_url).to eq("http://www.foo.com")
    end
  end
end
