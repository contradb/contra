require 'rails_helper'

describe Tag do
  it '#dances relationship is a little silly because it allows dupes' do
    dut = FactoryGirl.create(:dut)
    tag = dut.tag
    dance = dut.dance
    FactoryGirl.create(:dut, dance: dance, tag: tag)
    expect(tag.dances.length).to eq(2)
    expect(tag.dances.to_a).to eq([dance, dance])
  end

  describe '#documentation' do
    it do
      tag = Tag.find_by(name: 'verified')
      expect(tag.documentation(me: false, other_count: 0)).to eq(tag.off_sentence)
    end
  end
end
