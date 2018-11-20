require 'rails_helper'

describe User do
  it '#dialect' do
    user = FactoryGirl.build(:user)
    user.idioms.build(FactoryGirl.attributes_for(:move_idiom, term: 'gyre', substitution: 'darcy'))
    user.idioms.build(FactoryGirl.attributes_for(:move_idiom, term: 'meltdown swing', substitution: 'gyre meltdown'))
    user.idioms.build(FactoryGirl.attributes_for(:dancer_idiom, term: 'ladles', substitution: 'ravens'))
    user.idioms.build(FactoryGirl.attributes_for(:dancer_idiom, term: 'gentlespoons', substitution: 'larks'))
    dialect = user.dialect
    expect(dialect.length).to eq(2)
    expect(dialect['dancers'].length).to eq(2)
    expect(dialect['dancers']['ladles']).to eq('ravens')
    expect(dialect['dancers']['gentlespoons']).to eq('larks')
    expect(dialect['moves'].length).to eq(2)
    expect(dialect['moves']['gyre']).to eq('darcy')
    expect(dialect['moves']['meltdown swing']).to eq('gyre meltdown')
  end

  describe 'idioms' do
    describe 'relationship' do
      it 'exists' do
        expect(FactoryGirl.build(:user).idioms).to eq([])
      end

      it 'dependant destroy works' do
        user = FactoryGirl.create(:user)
        idiom = user.idioms.create(FactoryGirl.attributes_for(:move_idiom))
        user.destroy!
        expect(Idiom::Idiom.find_by(id: idiom.id)).to eq(nil)
        expect(Idiom::Move.find_by(id: idiom.id)).to eq(nil)
      end
    end
  end

  describe 'tags' do
    let (:dut) {FactoryGirl.create(:dut)}
    it '# duts association' do
      expect(dut.user.duts.to_a).to eq([dut])
    end
  end
end
