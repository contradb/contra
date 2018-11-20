require 'rails_helper'

describe Tag do
  let (:dut) {FactoryGirl.create(:dut)}

  it '#dances relationship is a little silly because it allows dupes' do
    tag = dut.tag
    dance = dut.dance
    FactoryGirl.create(:dut, dance: dance, tag: tag)
    expect(tag.dances.length).to eq(2)
    expect(tag.dances.to_a).to eq([dance, dance])
  end
end
