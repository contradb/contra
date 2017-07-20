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

  describe '#moves' do
    it 'works' do
      expect(FactoryGirl.build(:box_the_gnat_contra).moves).to eq(['box the gnat',
                                                                   'swat the flea',
                                                                   'swing',
                                                                   'allemande',
                                                                   'swing',
                                                                   'right left through',
                                                                   'chain'])
    end

    it "passes 'empty figure' through as nil" do
      expect(FactoryGirl.build(:dance_with_empty_figure).moves).to eq(['swing', nil])
    end
  end

  describe "#moves_that_precede_move" do
    it 'works' do
      dance = FactoryGirl.build(:box_the_gnat_contra)
      expect(dance.moves_that_precede_move('swat the flea')).to eq(Set.new(['box the gnat']))
    end

    it "glosses over 'empty figure'" do
      dance = FactoryGirl.build(:dance_with_empty_figure)
      expect(dance.moves_that_precede_move('swing')).to eq(Set.new(['swing']))
    end
  end

  describe "#moves_that_follow_move" do
    it 'works' do
      dance = FactoryGirl.build(:box_the_gnat_contra)
      expect(dance.moves_that_follow_move('box the gnat')).to eq(Set.new(['swat the flea']))
    end

    it "glosses over 'empty figure'" do
      dance = FactoryGirl.build(:dance_with_empty_figure)
      expect(dance.moves_that_follow_move('swing')).to eq(Set.new(['swing']))
    end
  end

  describe '#beats' do
    it 'works on a real dance' do
      expect(FactoryGirl.build(:box_the_gnat_contra).beats).to eq(64)
    end

    it 'works on a dance with a bogus figure' do
      # :dance_with_empty_figure = long swing(16) + empty figure(8, defaulted)
      expect(FactoryGirl.build(:dance_with_empty_figure).beats).to be_a(Integer)
    end
  end

  it '#stompiness works' do
    expect(FactoryGirl.build(:balances).stompiness).to eq(16.0 / 32.0)
  end
end
