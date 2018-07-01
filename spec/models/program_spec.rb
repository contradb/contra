require 'rails_helper'
require 'spec_helper'

describe Program, type: :model do
  describe 'factory' do
    it 'produces valid programs' do
      expect(FactoryGirl.build(:program)).to be_valid
    end

    it ':dances transient attribute stuffs some dances into activities' do
      dance = FactoryGirl.create(:dance)
      program = FactoryGirl.create(:program, dances: [dance])
      expect(program.activities.length).to eq(1)
      expect(program.activities.first.dance.title).to eq(dance.title)
    end
  end

  describe "collections of programs" do
    it "returns all programs in case-insensitive alphabetical order" do
      titles = ["AAAA","BBBB","cccc","DDDD"]
      titles.each {|title| FactoryGirl.create :program, title: title }
      expect(Program.all.pluck(:title)).to eq ["AAAA","BBBB","cccc","DDDD"]
    end
  end

  describe "an individual program" do
    before (:each) do
      @program = FactoryGirl.create(:program)
      expect(@program.activity_integrity?).to be true
    end
    after (:each) do
      expect(@program.activity_integrity?).to be true
    end

    it "starts with zero activities" do
      expect(@program.activities_length).to be == 0
    end

    it "sanity check append_new_activity & activities_length" do
      @program.append_new_activity(text: "a")
      @program.append_new_activity(text: "b")
      @program.append_new_activity(text: "c")

      expect(@program.activities_length).to be == 3
      expect(@program.activities_sorted.map(&:text)).to be == ["a","b","c"]
    end
  end

  it '#destroy also destroys activities but not dances' do
    user = FactoryGirl.create(:user)
    dance = FactoryGirl.create(:dance, user: user)
    program = FactoryGirl.create(:program, dances: [dance], user: user)
    activity = program.activities.first
    program.destroy!
    expect(Dance.find_by(id: dance.id)).to be_a(Dance)
    expect(Activity.find_by(id: activity.id)).to be(nil)
  end
end
