require 'rails_helper'
# require 'spec_helper'
# require 'app/datatables/dance_datatable.rb'

describe DanceDatatable do
  describe '.filter_dances' do
    let (:dances) { [:dance, :box_the_gnat_contra, :call_me].map {|name| FactoryGirl.create(name)} }

    describe 'figure' do
      it 'works' do
        filtered = DanceDatatable.send(:filter_dances, dances, ['figure', 'hey'])
        expect(filtered.map(&:title)).to eq(['Call Me'])
      end

      it 'wildcard' do
        filtered = DanceDatatable.send(:filter_dances, dances, ['figure', '*'])
        expect(filtered.map(&:title)).to eq(dances.map(&:title))
      end

      it "quotes and spaces work - Rory O'Moore" do      # something about this figure didn't work -dm 10-15-2017
        rory = FactoryGirl.create(:dance_with_a_rory_o_moore);
        dances << rory
        filtered = DanceDatatable.send(:filter_dances, dances, ['figure', "Rory O'Moore"])
        expect(filtered.map(&:title)).to eq([rory.title])
      end

      it 'circle works with an angle' do
        filtered = DanceDatatable.send(:filter_dances, dances, ['figure', 'circle', '*', 360, '*'])
        expect(filtered.map(&:title)).to eq(['The Rendevouz'])
      end

      it "'shadow' finds both 'shadow' and '2nd shadow'" do
        first_shadow = FactoryGirl.create(:dance_with_pair, pair: 'shadows')
        second_shadow = FactoryGirl.create(:dance_with_pair, pair: '2nd shadows')
        augmented_dances = dances + [first_shadow, second_shadow]
        filtered = DanceDatatable.send(:filter_dances, augmented_dances, ['figure', 'swing', 'shadows', '*', '*'])
        expect(filtered.map(&:title).sort).to eq([first_shadow.title, second_shadow.title])
      end

      it "'neighbors' finds 'neigbhors', 'prev neighbors', 'next neighbors', '3rd neighbors', and '4th neighbors'" do
        augmented_dances = dances + ['prev neighbors', 'next neighbors', '3rd neighbors', '4th neighbors', 'partners'].map {|n|
          FactoryGirl.create(:dance_with_pair, pair: n)
        }
        partners_should_not_match = augmented_dances.last
        filtered = DanceDatatable.send(:filter_dances, augmented_dances, ['figure', 'swing', 'neighbors', '*', '*'])
        expect(filtered.map(&:title).sort).to eq(augmented_dances.map(&:title).sort - [partners_should_not_match.title])
      end
    end

    describe 'and' do
      it 'works' do
        filtered = DanceDatatable.send(:filter_dances, dances, ['and', ['figure', 'circle'], ['figure', 'right left through']])
        expect(filtered.map(&:title)).to eq(['Call Me'])
      end

      it 'works with no' do
        filtered = DanceDatatable.send(:filter_dances, dances, ['and', ['no', ['figure', 'chain']], ['figure', 'star']])
        expect(filtered).to eq([])        
      end
    end

    it 'or' do
      filtered = DanceDatatable.send(:filter_dances, dances, ['or', ['figure', 'circle'], ['figure', 'right left through']])
      expect(filtered.map(&:title)).to eq(dances.map(&:title))
    end

    it 'no' do
      filtered = DanceDatatable.send(:filter_dances, dances, ['no', ['figure', 'hey']])
      expect(filtered.map(&:title)).to eq(['The Rendevouz', 'Box the Gnat Contra'])
    end

    it 'all' do
      dances2 = [FactoryGirl.create(:dance_with_a_swing)] + dances
      filtered = DanceDatatable.send(:filter_dances, dances2, ['all', ['figure', 'swing']])
      expect(filtered.map(&:title)).to eq(['Monofigure'])
    end

    it 'anything but' do
      dances2 = [FactoryGirl.create(:dance_with_a_swing)] + dances
      filtered = DanceDatatable.send(:filter_dances, dances2, ['anything but', ['figure', 'swing']])
      expect(filtered.map(&:title)).to eq(['The Rendevouz', 'Box the Gnat Contra', 'Call Me'])
    end

    describe 'then' do
      it 'basically works' do
        filtered = DanceDatatable.send(:filter_dances, dances, ['then', ['figure', 'swing'], ['figure', 'circle']])
        expect(filtered.map(&:title)).to eq(['The Rendevouz', 'Call Me'])
      end

      it 'works with anything but' do
        # All the swings in Call Me are immediately followed by either a circle or a right left through.
        filtered = DanceDatatable.send(:filter_dances, dances, ['then', ['figure', 'swing'], ['anything but', ['or', ['figure', 'circle'], ['figure', 'right left through']]]])
        expect(filtered.map(&:title)).to eq(['The Rendevouz', 'Box the Gnat Contra'])
      end
    end
  end

  describe '.shift_figure_indicies' do
    it 'basically works' do
      expect(DanceDatatable.shift_figure_indicies([1,3,5], 7)).to eq([2,4,6])
    end

    it 'wraps' do
      expect(DanceDatatable.shift_figure_indicies([5], 6)).to eq([0])
    end
  end

  describe '.matching_figures_for_then' do
    it 'basically works' do
      dance = FactoryGirl.create(:box_the_gnat_contra)
      figure_indicies = DanceDatatable.matching_figures(['then', ['figure', 'box the gnat'], ['figure', 'swat the flea']], dance)
      expect(figure_indicies).to eq([1])
    end

    it 'wraps' do
      dance = FactoryGirl.create(:dance)
      figure_indicies = DanceDatatable.matching_figures(['then', ['figure', 'circle'], ['figure', 'swing']], dance)
      expect(figure_indicies).to eq([0])
    end

    it 'returns everything with zero arguments' do
      dance = FactoryGirl.create(:dance)
      figure_indicies = DanceDatatable.matching_figures(['then'], dance)
      expect(figure_indicies).to eq([*(0...dance.figures.length)])
    end

    it 'returns index of figure with one argument' do
      dance = FactoryGirl.create(:dance)
      figure_indicies = DanceDatatable.matching_figures(['then', ['figure', 'circle']], dance)
      expect(figure_indicies).to eq([4,6])
    end
  end

  describe '.hash_to_array' do
    it 'works' do
      h = {'faux_array' => true, "0" => 'figure', "1" => 'swing'}
      expect(DanceDatatable.send(:hash_to_array, h)).to eq(['figure', 'swing'])
    end

    it 'is recursive' do
      h = {'faux_array' => true, "0" => 'anything but', "1" => {'faux_array' => true, "0" => 'figure', "1" => 'swing'}}
      expect(DanceDatatable.send(:hash_to_array, h)).to eq(['anything but', ['figure', 'swing']])
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
