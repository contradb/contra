# coding: utf-8
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
    let (:tag) {Tag.find_by(name: 'verified')}

    it 'nobody → off_sentence' do
      expect(tag.documentation(me: false)).to eq(tag.off_sentence)
    end

    it 'one other person → "1 user #{on_verb_3rd_person_singular} #{on_sentence}"' do
      expect(tag.documentation(other_count: 1)).to eq("1 user #{tag.on_verb_3rd_person_singular} #{tag.on_phrase}")
    end

    it 'this person → "you #{on_sentence}"' do
      expect(tag.documentation(me: true)).to eq("you #{tag.on_verb} #{tag.on_phrase}")
    end

    it 'this person and others → "2 users #{on_sentence}"' do
      expect(tag.documentation(me: true, other_count: 1)).to eq("2 users #{tag.on_verb} #{tag.on_phrase}")
    end
  end
end
