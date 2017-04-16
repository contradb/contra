require 'rails_helper'

RSpec.describe Dance, type: :model do
  it "'alphabetical' scope returns dances in case-insensitive alphabetical order" do
    titles = ["AAAA","DDDD","cccc","BBBB"]
    titles.each {|title| FactoryGirl.create :dance, title: title }
    expect(Dance.alphabetical.pluck(:title)).to eq ["AAAA","BBBB","cccc","DDDD"]
  end
  describe "'published_for' scope" do
    let! (:admonsterator) { FactoryGirl.create(:user, is_admin: true) }
    let (:user_a) { FactoryGirl.create(:user) }
    let (:user_b) { FactoryGirl.create(:user) }
    let! (:dance_a1) { FactoryGirl.create(:dance, user: user_a, title: "dance a1", publish: false) }
    let! (:dance_a2) { FactoryGirl.create(:dance, user: user_a, title: "dance a2", publish: true) }
    let! (:dance_b1) { FactoryGirl.create(:dance, user: user_b, title: "dance b1", publish: false) }
    let! (:dance_b2) { FactoryGirl.create(:dance, user: user_b, title: "dance b2", publish: true) }

    it "if not passed a user just returns published dances" do
      expect(Dance.published_for(nil).pluck(:title)).to eq(['dance a2', 'dance b2'])
    end

    it "if passed a user, only returns published dances or dances of that user" do
      expect(Dance.published_for(user_b).pluck(:title)).to eq(['dance a2', 'dance b1', 'dance b2'])
    end

    it "if passed an admin, returns all dances" do
      expect(admonsterator.is_admin).to be(true)
      expect(Dance.published_for(admonsterator).pluck(:title)).to eq(['dance a1', 'dance a2', 'dance b1', 'dance b2'])
    end
  end
end
