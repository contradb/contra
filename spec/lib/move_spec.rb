require 'move'
require 'rails_helper'

RSpec.describe Move do
  let (:prefs) { JSLibFigure.stub_prefs }

  pending 'tests for coappearing_mdtab'

  describe ".mdtab" do
    it 'returns a hash' do
      expect(Move.mdtab([], prefs)).to eq({})
    end

    it 'hash maps moves to dances' do
      dance = FactoryGirl.build(:dance_with_a_swing)
      expect(Move.mdtab([dance], prefs)).to eq({'swing' => Set.new([dance])})
    end

    it 'works with larger numbers of dances and figures' do
      dance = FactoryGirl.build(:dance_with_a_swing)
      dance2 = FactoryGirl.build(:box_the_gnat_contra)
      index = Move.mdtab([dance,dance2], prefs)
      expect(index['swing']).to eq(Set.new([dance,dance2]))
      expect(index['box the gnat']).to eq(Set.new([dance2]))
      expect(index['long lines']).to be_blank
    end
  end

  describe ".following_mdtab" do
    it "works" do
      box_the_gnat = FactoryGirl.build(:box_the_gnat_contra)
      expected = {'allemande'=>Set.new([box_the_gnat]),
                  'right left through'=>Set.new([box_the_gnat])}
      expect(Move.following_mdtab([box_the_gnat], 'swing', prefs)).to eq(expected)
    end

    it "works off the end of the array" do
      dance = FactoryGirl.build(:dance)
      expected = {'slide along set'=>Set.new([dance]), 'swing'=>Set.new([dance])}
      expect(Move.following_mdtab([dance], 'circle', prefs)).to eq(expected)
    end

    it "works with two dances with partially overlapping moves" do
      call_me = FactoryGirl.build(:call_me)
      box_the_gnat = FactoryGirl.build(:box_the_gnat_contra)
      expected = {'allemande'=>Set.new([box_the_gnat]), 'right left through'=>Set.new([box_the_gnat, call_me]), 'circle'=>Set.new([call_me])}
      expect(Move.following_mdtab([box_the_gnat, call_me], 'swing', prefs)).to eq(expected)
    end
  end

  describe ".preceeding_mdtab" do
    it "works" do
      box_the_gnat = FactoryGirl.build(:box_the_gnat_contra)
      expected = {'swat the flea'=>Set.new([box_the_gnat]), 'allemande'=>Set.new([box_the_gnat])}
      expect(Move.preceeding_mdtab([box_the_gnat], 'swing', prefs)).to eq(expected)
    end

    it "works off the end of the array" do
      box_the_gnat = FactoryGirl.build(:box_the_gnat_contra)
      expected = {'chain'=>Set.new([box_the_gnat])}
      expect(Move.preceeding_mdtab([box_the_gnat], 'box the gnat', prefs)).to eq(expected)
    end

  end
end
