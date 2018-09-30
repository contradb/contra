require 'rails_helper'

describe Blog do
  it 'factory works' do
    FactoryGirl.build(:blog)
  end

  describe '#readable?' do
    it 'with no user returns publish bit' do
      expect(FactoryGirl.build(:blog, publish: true).readable?).to be(true)
      expect(FactoryGirl.build(:blog, publish: false).readable?).to be(false)
    end

    it 'with random user returns publish bit' do
      user = FactoryGirl.build(:user, blogger: false, admin: false)
      expect(FactoryGirl.build(:blog, publish: true).readable?(user)).to be(true)
      expect(FactoryGirl.build(:blog, publish: false).readable?(user)).to be(false)
    end

    it 'with blogger returns true' do
      user = FactoryGirl.build(:user, blogger: true, admin: false)
      expect(FactoryGirl.build(:blog, publish: true).readable?(user)).to be(true)
      expect(FactoryGirl.build(:blog, publish: false).readable?(user)).to be(true)
    end

    it 'with admin returns true' do
      user = FactoryGirl.build(:user, blogger: false, admin: true)
      expect(FactoryGirl.build(:blog, publish: true).readable?(user)).to be(true)
      expect(FactoryGirl.build(:blog, publish: false).readable?(user)).to be(true)
    end
  end

  describe '#writable?' do
    it 'with no user returns false' do
      expect(FactoryGirl.build(:blog).writeable?).to be(false)
    end

    it 'with random user returns false' do
      user = FactoryGirl.build(:user, blogger: false, admin: false)
      expect(FactoryGirl.build(:blog).writeable?(user)).to be(false)
    end

    it 'with blogger returns true' do
      user = FactoryGirl.build(:user, blogger: true, admin: false)
      expect(FactoryGirl.build(:blog).writeable?(user)).to be(true)
    end

    it 'with admin returns true' do
      user = FactoryGirl.build(:user, blogger: false, admin: true)
      expect(FactoryGirl.build(:blog).writeable?(user)).to be(true)
    end
  end
end
