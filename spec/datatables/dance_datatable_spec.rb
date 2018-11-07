# coding: utf-8
require 'rails_helper'
# require 'spec_helper'
# require 'app/datatables/dance_datatable.rb'

describe DanceDatatable do
  describe '.filter_dances' do
    let (:dances) { [:dance, :box_the_gnat_contra, :call_me, :dance_with_zero_figures].map {|name| FactoryGirl.create(name)} }
    let (:zero) { dances.last }
    let (:dance_titles_without_zero) { dances.map(&:title) - [dances.last.title]}

    describe 'figure' do
      it 'works' do
        filtered = DanceDatatable.send(:filter_dances, dances, ['figure', 'hey'])
        expect(filtered.map(&:title)).to eq(['Call Me'])
      end

      it 'wildcard' do
        filtered = DanceDatatable.send(:filter_dances, dances, ['figure', '*'])
        expect(filtered.map(&:title)).to eq(dance_titles_without_zero)
      end

      it "quotes and spaces work - Rory O'More" do      # something about this figure didn't work -dm 10-15-2017
        rory = FactoryGirl.create(:dance_with_a_rory_o_more);
        dances << rory
        filtered = DanceDatatable.send(:filter_dances, dances, ['figure', "Rory O'More"])
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
        expect(filtered.map(&:title).sort).to eq(augmented_dances.map(&:title).sort - [partners_should_not_match.title, zero.title])
      end
    end

    describe 'formation' do
      # there's some heavier testing of this in features/welcome/index_spec.rb -dm 08-19-2018
      it 'Becket ccw' do
        dances
        filtered = DanceDatatable.send(:filter_dances, dances, ['formation', 'Becket ccw'])
        expect(filtered.map(&:title)).to eq(['Call Me'])
      end

      it 'improper' do
        dances
        filtered = DanceDatatable.send(:filter_dances, dances, ['formation', 'improper'])
        expect(filtered.map(&:title).sort).to eq((dances.map(&:title) - ['Call Me']).sort)
      end

      it 'everything else' do
        dances2 = dances + [FactoryGirl.create(:dance, start_type: 'circle mixer', title: 'wacky')]
        filtered = DanceDatatable.send(:filter_dances, dances2, ['formation', 'everything else'])
        expect(filtered.map(&:title)).to eq(['wacky'])
      end
    end

    it 'progression' do
      dances
      filtered = DanceDatatable.send(:filter_dances, dances, ['progression'])
      expect(filtered.map(&:title)).to eq(["The Rendevouz", "Box the Gnat Contra", "Call Me"])
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

    it '& works with progression' do
      filtered = DanceDatatable.send(:filter_dances, dances, ['&', ['figure', 'slide along set'], ['progression']])
      expect(filtered.map(&:title)).to eq(['The Rendevouz'])
    end

    it 'or' do
      filtered = DanceDatatable.send(:filter_dances, dances, ['or', ['figure', 'circle'], ['figure', 'right left through']])
      expect(filtered.map(&:title)).to eq(dance_titles_without_zero)
    end

    it 'no' do
      filtered = DanceDatatable.send(:filter_dances, dances, ['no', ['figure', 'hey']])
      expect(filtered.map(&:title)).to eq(['The Rendevouz', 'Box the Gnat Contra', zero.title])
    end

    it 'all' do
      dances2 = [:dance_with_a_swing, :dance_with_a_do_si_do].map {|d| FactoryGirl.create(d)} + dances
      filtered = DanceDatatable.send(:filter_dances, dances2, ['all', ['figure', 'swing']])
      expect(filtered.map(&:title)).to eq([dances2.first.title, zero.title])
    end

    it 'not' do
      dances2 = [FactoryGirl.create(:dance_with_a_swing)] + dances
      filtered = DanceDatatable.send(:filter_dances, dances2, ['not', ['figure', 'swing']])
      expect(filtered.map(&:title)).to eq(['The Rendevouz', 'Box the Gnat Contra', 'Call Me'])
    end

    describe 'then' do
      it 'basically works' do
        filtered = DanceDatatable.send(:filter_dances, dances, ['then', ['figure', 'swing'], ['figure', 'circle']])
        expect(filtered.map(&:title)).to eq(['The Rendevouz', 'Call Me'])
      end

      it 'works with not' do
        # All the swings in Call Me are immediately followed by either a circle or a right left through.
        filtered = DanceDatatable.send(:filter_dances, dances, ['then', ['figure', 'swing'], ['not', ['or', ['figure', 'circle'], ['figure', 'right left through']]]])
        expect(filtered.map(&:title)).to eq(['The Rendevouz', 'Box the Gnat Contra'])
      end
    end

    describe 'count' do
      let (:all_titles) { dances.map(&:title) }

      def filtered_titles(comparison, number)
        DanceDatatable.send(:filter_dances, dances, ['count', ['figure', 'circle'], comparison, number.to_s]).map(&:title)
      end

      it '≥ 2' do
        expect(filtered_titles('≥', 2)).to eq(['The Rendevouz'])
      end

      it '< 2' do
        expect(filtered_titles('<', 2)).to eq(all_titles - ['The Rendevouz'])
      end

      it '≠ 1' do
        expect(filtered_titles('≠', 1)).to eq(all_titles - ['Call Me'])
      end

      it '= 1' do
        expect(filtered_titles('=', 1)).to eq(['Call Me'])
      end

    end
  end

    it '.matching_figures_for_progression only works on figures with progressions' do
      dance = FactoryGirl.create(:box_the_gnat_contra)
      f = dance.figures
      f[3]['progression'] = 1
      dance.figures = f
      nfigures = dance.figures.length
      search_matches = DanceDatatable.matching_figures(['progression'], dance)
      expect(search_matches).to eq(Set[SearchMatch.new(nfigures-1, nfigures),SearchMatch.new(3, nfigures)])
    end

  describe '.matching_figures_for_then' do
    it 'basically works' do
      dance = FactoryGirl.create(:box_the_gnat_contra)
      nfigures = dance.figures.length
      search_matches = DanceDatatable.matching_figures(['then', ['figure', 'box the gnat'], ['figure', 'swat the flea']], dance)
      expect(search_matches).to eq(Set[SearchMatch.new(0, nfigures, count: 2)])
    end

    it 'wraps' do
      dance = FactoryGirl.create(:dance)
      nfigures = dance.figures.length
      search_matches = DanceDatatable.matching_figures(['then', ['figure', 'circle'], ['figure', 'swing']], dance)
      expect(nfigures).to eq(7)
      expect(search_matches).to eq(Set[SearchMatch.new(6, nfigures, count: 2)])
      expect(search_matches.first.last).to eq(0)
    end

    it 'with zero arguments, returns all the zero-length matches' do
      dance = FactoryGirl.create(:dance)
      nfigures = dance.figures.length
      search_matches = DanceDatatable.matching_figures(['then'], dance)
      expect(search_matches).to eq(Set.new(nfigures.times.map {|i| SearchMatch.new(i, nfigures, count: 0)}))
    end

    it 'with one argument returns submatch' do
      dance = FactoryGirl.create(:dance)
      nfigures = dance.figures.length
      figure_indicies = DanceDatatable.matching_figures(['then', ['figure', 'circle']], dance)
      expect(figure_indicies).to eq(Set[SearchMatch.new(4, nfigures),
                                        SearchMatch.new(6, nfigures)])
    end


    it 'striping test' do
      dance = FactoryGirl.create(:dance)
      dance.update!(figures_json: '[{"parameter_values":["neighbors","none",8],"move":"swing"},
                                    {"parameter_values":[true,360,8],"move":"circle"},
                                    {"parameter_values":["neighbors","none",8],"move":"swing"},
                                    {"parameter_values":[true,360,8],"move":"circle"},
                                    {"parameter_values":["neighbors","none",8],"move":"swing"},
                                    {"parameter_values":[true,360,8],"move":"circle"},
                                    {"parameter_values":[true, 8],"move":"long lines"},
                                    {"parameter_values":["ladles",true,540,8],"move":"do si do", "progression": 1}]')
      nfigures = dance.figures.length
      q1 = ['then', ['figure', 'circle']]
      q2 = ['then', ['figure', 'circle'], ['figure', 'swing']]
      q3 = ['then', ['figure', 'circle'], ['figure', 'swing'], ['figure', 'circle']]
      q5 = ['then', ['figure', 'circle'], ['figure', 'swing'], ['figure', 'circle'], ['figure', 'swing'], ['figure', 'circle']]
      q6 = ['then', ['figure', 'circle'], ['figure', 'swing'], ['figure', 'circle'], ['figure', 'swing'], ['figure', 'circle'], ['figure', 'swing']]
      expect(DanceDatatable.matching_figures(q1, dance)).to eq(search_match_indicies([1, 3, 5], nfigures, count: 1))
      expect(DanceDatatable.matching_figures(q2, dance)).to eq(search_match_indicies([1, 3], nfigures, count: 2))
      expect(DanceDatatable.matching_figures(q3, dance)).to eq(search_match_indicies([1, 3], nfigures, count: 3))
      expect(DanceDatatable.matching_figures(q5, dance)).to eq(search_match_indicies([1], nfigures, count: 5))
      expect(DanceDatatable.matching_figures(q6, dance)).to eq(nil)
    end

    def search_match_indicies(indicies, nfigures, count: 1)
      Set.new(indicies.map {|i| SearchMatch.new(i, nfigures, count: count)})
    end

    describe 'nested thens' do
      # circle, swing, circle, do si do
      let (:dance) { FactoryGirl.create(:dance).tap {|d| d.update!(figures_json: '[{"parameter_values":[true,360,8],"move":"circle"},{"parameter_values":["neighbors","none",8],"move":"swing"},{"parameter_values":[true,360,8],"move":"circle"},{"parameter_values":["ladles",true,540,8],"move":"do si do", "progression": 1}]')}}
      let (:nfigures) {dance.figures.length}
      let (:q1) {['then', ['figure', 'circle'],                             ['then', ['figure', 'swing'], ['figure', 'circle']]]}
      let (:q2) {['then', ['figure', 'circle'], ['or', ['figure', 'swing'], ['then', ['figure', 'swing'], ['figure', 'circle']]]]}

      it 'works' do
        expect(DanceDatatable.matching_figures(q1, dance)).to eq(Set[SearchMatch.new(0,nfigures, count: 3)])
      end

      it 'superimpose' do
        expect(DanceDatatable.matching_figures(q2, dance)).to eq(Set[SearchMatch.new(0,nfigures, count: 3), SearchMatch.new(0,nfigures, count: 2)])
      end
    end

    it "issue #461 regression - nested thens" do
      dance = FactoryGirl.create(:you_cant_get_there_from_here)
      q = ["then",
           ["or",
            ["figure","form an ocean wave"],
            ["figure","form long waves"]],
           ["or",
            ["figure","allemande"],
            ["then",
             ["figure","balance"],
             ["figure","allemande"]]]]
      expect(DanceDatatable.matching_figures(q, dance)).to eq(Set[SearchMatch.new(12, 13, count: 3),
                                                                  SearchMatch.new(2, 13, count: 3)])
    end
  end

  describe '.hash_to_array' do
    it 'works' do
      h = {'faux_array' => true, "0" => 'figure', "1" => 'swing'}
      expect(DanceDatatable.send(:hash_to_array, h)).to eq(['figure', 'swing'])
    end

    it 'is recursive' do
      h = {'faux_array' => true, "0" => 'not', "1" => {'faux_array' => true, "0" => 'figure', "1" => 'swing'}}
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

  it '.dice_search_matches' do
    result = DanceDatatable.send(:dice_search_matches, Set[SearchMatch.new(7,8, count: 2), SearchMatch.new(6,8, count:2)])
    expect(result).to eq(Set[SearchMatch.new(6,8),
                             SearchMatch.new(7,8),
                             SearchMatch.new(0,8)])
  end
end
