require 'rails_helper'

RSpec.describe Dance, type: :model do
  it "'alphabetical' scope returns dances in case-insensitive alphabetical order" do
    titles = ["AAAA","DDDD","cccc","BBBB"]
    titles.each {|title| FactoryGirl.create :dance, title: title }
    expect(Dance.alphabetical.pluck(:title)).to eq ["AAAA","BBBB","cccc","DDDD"]
  end

  describe "permissions" do 
    let! (:admonsterator) { FactoryGirl.create(:user, admin: true) }
    let (:user_a) { FactoryGirl.create(:user) }
    let (:user_b) { FactoryGirl.create(:user) }
    let! (:dance_a1) { FactoryGirl.create(:dance, user: user_a, title: "dance a1", publish: false) }
    let! (:dance_a2) { FactoryGirl.create(:dance, user: user_a, title: "dance a2", publish: true) }
    let! (:dance_b1) { FactoryGirl.create(:dance, user: user_b, title: "dance b1", publish: false) }
    let! (:dance_b2) { FactoryGirl.create(:dance, user: user_b, title: "dance b2", publish: true) }
    let (:dances) { [dance_a1, dance_a2, dance_b1, dance_b2] }

    describe '#readable?' do
      it "with nil returns published dances" do
        expect(dances.map(&:readable?)).to eq([false,true,false,true])
      end

      it "with user returns their dances and published dances" do
        expect(dances.map {|d| d.readable?(user_a)}).to eq([true,true,false,true])
      end

      it "with admin returns all dances" do
        expect(dances.map {|d| d.readable?(admonsterator)}).to eq([true,true,true,true])
      end
    end

    describe "'readable_by' scope" do
      it "if not passed a user just returns published dances" do
        expect(Dance.readable_by(nil).pluck(:title)).to eq(['dance a2', 'dance b2'])
      end

      it "if passed a user, only returns published dances or dances of that user" do
        expect(Dance.readable_by(user_b).pluck(:title)).to eq(['dance a2', 'dance b1', 'dance b2'])
      end

      it "if passed an admin, returns all dances" do
        expect(Dance.readable_by(admonsterator).pluck(:title)).to eq(['dance a1', 'dance a2', 'dance b1', 'dance b2'])
      end
    end
  end

  describe "move_index" do
    it 'returns a hash' do
      expect(Dance.move_index([])).to eq({})
    end

    it 'hash maps moves to dances' do
      dance = FactoryGirl.build(:dance_with_a_swing)
      expect(Dance.move_index([dance])).to eq({'swing' => Set.new([dance])})
    end

    it 'works with larger numbers of dances and figures' do
      dance = FactoryGirl.build(:dance_with_a_swing)
      dance2 = FactoryGirl.build(:box_the_gnat_contra)
      index = Dance.move_index([dance,dance2])
      expect(index['swing']).to eq(Set.new([dance,dance2]))
      expect(index['box the gnat']).to eq(Set.new([dance2]))
      expect(index['long lines']).to be_blank
    end
  end

  describe "#moves_that_precede_move" do
    it 'works' do
      dance = FactoryGirl.build(:box_the_gnat_contra)
      expect(dance.moves_that_precede_move('swat the flea')).to eq(Set.new(['box the gnat']))
    end
  end

  describe ".moves_and_dances_that_follow_move" do
    it "works" do
      box_the_gnat = FactoryGirl.build(:box_the_gnat_contra)
      expected = {'allemande'=>Set.new([box_the_gnat]),
                  'right left through'=>Set.new([box_the_gnat])}
      expect(Dance.moves_and_dances_that_follow_move([box_the_gnat], 'swing')).to eq(expected)
    end

    it "works off the end of the array" do
      dance = FactoryGirl.build(:dance)
      expected = {'slide along set'=>Set.new([dance]), 'swing'=>Set.new([dance])}
      expect(Dance.moves_and_dances_that_follow_move([dance], 'circle')).to eq(expected)
    end

    it "works with two dances with partially overlapping moves" do
      call_me = FactoryGirl.build(:call_me)
      box_the_gnat = FactoryGirl.build(:box_the_gnat_contra)
      expected = {'allemande'=>Set.new([box_the_gnat]), 'right left through'=>Set.new([box_the_gnat, call_me]), 'circle'=>Set.new([call_me])}
      expect(Dance.moves_and_dances_that_follow_move([box_the_gnat, call_me], 'swing')).to eq(expected)
    end
  end

  describe ".moves_and_dances_that_precede_move" do
    it "works" do
      box_the_gnat = FactoryGirl.build(:box_the_gnat_contra)
      expected = {'swat the flea'=>Set.new([box_the_gnat]), 'allemande'=>Set.new([box_the_gnat])}
      expect(Dance.moves_and_dances_that_precede_move([box_the_gnat], 'swing')).to eq(expected)
    end

    it "works off the end of the array" do
      box_the_gnat = FactoryGirl.build(:box_the_gnat_contra)
      expected = {'chain'=>Set.new([box_the_gnat])}
      expect(Dance.moves_and_dances_that_precede_move([box_the_gnat], 'box the gnat')).to eq(expected)
    end

  end

end
