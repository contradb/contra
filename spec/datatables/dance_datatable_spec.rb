require 'rails_helper'
# require 'spec_helper'
# require 'app/datatables/dance_datatable.rb'

describe DanceDatatable do
  describe '.filter_dances' do
    let (:dances) { [:dance, :box_the_gnat_contra, :call_me].map {|name| FactoryGirl.create(name)} }

    it 'figure' do
      filtered = DanceDatatable.send(:filter_dances, dances, ['figure', 'hey'])
      expect(filtered.map(&:title)).to eq(['Call Me'])
    end

    it 'and' do
      filtered = DanceDatatable.send(:filter_dances, dances, ['and', ['figure', 'circle'], ['figure', 'right left through']])
      expect(filtered.map(&:title)).to eq(['Call Me'])
    end

    it 'or' do
      filtered = DanceDatatable.send(:filter_dances, dances, ['or', ['figure', 'circle'], ['figure', 'right left through']])
      expect(filtered).to eq(dances)
    end

    it 'not' do
      filtered = DanceDatatable.send(:filter_dances, dances, ['not', ['figure', 'hey']])
      expect(filtered.map(&:title)).to eq(['The Rendevouz', 'Box the Gnat Contra'])
    end
  end


  describe '.hash_to_array' do
    it 'works' do
      h = {'faux_array' => true, 0 => 'figure', 1 => 'swing'}
      expect(DanceDatatable.send(:hash_to_array, h)).to eq(['figure', 'swing'])
    end

    it 'is recursive' do
      h = {'faux_array' => true, 0 => 'not', 1 => {'faux_array' => true, 0 => 'figure', 1 => 'swing'}}
      expect(DanceDatatable.send(:hash_to_array, h)).to eq(['not', ['figure', 'swing']])
    end

    it 'does not disturb hashes that do not have the faux_array key true' do
      h = {0 => 'chicken'}
      expect(DanceDatatable.send(:hash_to_array, h)).to eq(h)
    end

    it 'passes atoms undisturbed' do
      h = 42
      expect(DanceDatatable.send(:hash_to_array, h)).to eq(h)
    end

    # unspecified because I don't need it yet: 
    # what happens when you get a non faux_array and it has a faux_array as a key or value.
  end
end
