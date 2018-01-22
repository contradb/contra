require 'jslibfigure'
require 'rails_helper'

RSpec.describe JSLibFigure do
  def jseval(string)
    JSLibFigure.send(:eval, string) # hacking in
  end

  it 'an empty figure has 8 beats' do
    expect(JSLibFigure.beats(JSLibFigure.new)).to eql(8)
  end

  describe 'de_alias_move' do
    it 'see saw => do si do' do
      expect(JSLibFigure.de_alias_move('see saw')).to eql('do si do')
    end

    it 'allemande => allemande' do
      expect(JSLibFigure.de_alias_move('allemande')).to eql('allemande')
    end

    it 'swat the flea => box the gnat' do
      expect(JSLibFigure.de_alias_move('swat the flea')).to eql('box the gnat')
    end
  end

  describe 'aliases' do
    it 'do si do => [see saw]' do
      expect(JSLibFigure.aliases('do si do')).to eql(['see saw'])
    end

    it 'see saw => []' do
      expect(JSLibFigure.aliases('see saw')).to eql([])
    end
  end

  describe 'related_moves' do
    it 'long lines forward only => long lines' do
      expect(JSLibFigure.related_moves('allemande')).to include('allemande orbit')
    end
  end

  describe 'teaching_name' do
    it 'swing => swing' do
      expect(JSLibFigure.teaching_name('swing')).to eql('swing')
    end

    it 'allemande => allemande' do
      expect(JSLibFigure.teaching_name('allemande')).to eql('allemande')
    end

    it 'swat the flea => swat the flea' do
      expect(JSLibFigure.teaching_name('swat the flea')).to eql('swat the flea')
    end

    it '[empty figure] => "empty figure"' do
      expect(JSLibFigure.teaching_name(nil)).to eql('empty figure')
    end
  end

  describe 'moves' do
    it 'returns a list of length 20+' do
      expect(JSLibFigure.moves.length).to be > 20
    end

    it "includes 'swing'" do
      expect(JSLibFigure.moves).to include 'swing'
    end

    it "does not include 'gypsy'" do
      expect(JSLibFigure.moves).to_not include 'gypsy'
    end
  end

  describe 'movePreferencesForSelectMenu' do
    it "bumps 'swing' to the front of the line" do
      ms = JSLibFigure.eval('movePreferencesForSelectMenu(stubPrefs)') # empty prefs
      expect(ms.first['value']).to eq('swing')
      expect(ms.first['label']).to eq('swing')
      expect(ms.count {|m| m['value'] == 'swing'}).to eq(2)
      expect(ms.count {|m| m['label'] == 'swing'}).to eq(2)
    end

    it "doesn't copy swing if it's already aliased to something in the first 5 elements" do
      ms = JSLibFigure.eval("movePreferencesForSelectMenu({moves: {swing: 'america'}, dancers: {}})").dup
      expect(ms.index {|m| (m['label'] == 'america') && (m['value'] == 'swing')}).to be < 5 # if this fails there are maybe more than 5 moves alphabetically lower than 'america'?
      expect(ms.count {|m| m['label'] == 'america'}).to eq(1)
      expect(ms.count {|m| m['value'] == 'swing'}).to eq(1)
      expect(ms.count {|m| m['label'] == 'swing'}).to eq(0)
    end
  end

  describe 'slugify_move / deslugify_move' do
    it "slugify_move works for 'box the gnat'" do
      expect(JSLibFigure.slugify_move('box the gnat')).to eq('box-the-gnat')
    end
    it "deslugify_move works for 'box-the-gnat'" do
      expect(JSLibFigure.deslugify_move('box-the-gnat')).to eq('box the gnat')
    end
    JSLibFigure.moves.each do |move|
      it "#{move.inspect} >> slugify_move >> deslugify_move == #{move.inspect}" do
        expect(JSLibFigure.deslugify_move(JSLibFigure.slugify_move(move))).to eq(move)
      end
    end
  end

  it 'formal_parameters works' do
    params = JSLibFigure.formal_parameters('balance the ring')
    expect(params.length).to eq 1
    beats = params.first
    expect(beats['name']).to eq 'beats'
    expect(beats['value']).to eq 4
  end

  describe 'is_move?' do
    it "'circle' => true" do
      expect(JSLibFigure.is_move?('circle')).to be(true)
    end

    it "'flibbergibit' => false" do
      expect(JSLibFigure.is_move?('flibbergibit')).to be(false)
    end
  end

  describe 'angles_for_move' do
    it "'circle' => [90,180,270,360,450,540,630,720,810,900]" do
      expect(JSLibFigure.angles_for_move('circle')).to eq([90,180,270,360,450,540,630,720,810,900])
    end

    it "'allemande' => [90,180,270,360,450,540,630,720,810,900]" do
      expect(JSLibFigure.angles_for_move('allemande')).to eq([90,180,270,360,450,540,630,720,810,900])
    end

    it "'square through' => [180, 270, 360]" do
      expect(JSLibFigure.angles_for_move('square through')).to eq([180, 270, 360])
    end

    it "'box circulate' => [90, 180, 270, 360]" do
      expect(JSLibFigure.angles_for_move('box circulate')).to eq([90, 180, 270, 360])
    end
  end

  describe 'degrees_to_words' do
    it "(90, 'circle') => '1 place'" do
      expect(JSLibFigure.degrees_to_words(270, 'circle')).to eq('3 places')
    end

    it "(270, 'circle') => '3 places'" do
      expect(JSLibFigure.degrees_to_words(270, 'circle')).to eq('3 places')
    end

    it "(360, 'circle') => '4 places'" do
      expect(JSLibFigure.degrees_to_words(360, 'circle')).to eq('4 places')
    end

    it "(360, 'allemande') => 'once'" do
      expect(JSLibFigure.degrees_to_words(360, 'allemande')).to eq('once')
    end
 
    it "(90) => '90 degrees'" do
      expect(JSLibFigure.degrees_to_words(90)).to eq('90 degrees')
    end
  end

  it 'wrist_grips' do
    expect(JSLibFigure.wrist_grips).to eq(['', 'wrist grip', 'hands across'])
  end

  it 'parameter_uses_chooser' do
    formal_parameter = JSLibFigure.formal_parameters('swing').first
    expect(JSLibFigure.parameter_uses_chooser(formal_parameter, 'chooser_pairz')).to be(true)
    expect(JSLibFigure.parameter_uses_chooser(formal_parameter, 'chooser_half_or_full')).to be(false)
  end

  it 'stub_prefs' do
    expect(JSLibFigure.stub_prefs).to eq({'dancers' => {}, 'moves' => {}})
  end

  describe 'prefs_for_figures' do
    let (:empty_prefs) {{'dancers' => {}, 'moves' => {}}}

    it 'does nothing to a dance that is all in-set' do
      expect(JSLibFigure.prefs_for_figures(empty_prefs,FactoryGirl.build(:box_the_gnat_contra).figures)).to eq(empty_prefs)
    end

    it "rewrites 'next neighbors' to '2nd neighbors' when '3rd neighbors' are present" do
      figures = FactoryGirl.build(:dance_with_pair, pair: '3rd neighbors').figures
      expect(JSLibFigure.prefs_for_figures(empty_prefs, figures)['dancers']).to eq({'next neighbors' => '2nd neighbors'})
    end

    it "rewrites 'shadows' to '1st shadows' when '2nd shadows' are present" do
      figures = FactoryGirl.build(:dance_with_pair, pair: '2nd shadows').figures
      expect(JSLibFigure.prefs_for_figures(empty_prefs, figures)['dancers']).to eq({'shadows' => '1st shadows'})
    end
  end

  describe 'dancers_category' do
    it "returns 'shadows' for 'shadows'" do
      expect(JSLibFigure.dancers_category('partners')).to eq('partners')
    end

    it "returns 'neighbors' for 'prev neighbors'" do
      expect(JSLibFigure.dancers_category('prev neighbors')).to eq('neighbors')
    end

    it "returns 'shadows' for '2nd shadows'" do
      expect(JSLibFigure.dancers_category('prev neighbors')).to eq('neighbors')
    end
  end

  it 'formal_param_is_dancers works' do
    # representative samplings:
    nopes = %w(param_balance_false param_beats_8 param_spin_ccw param_left_shoulder_spin param_four_places param_star_grip)
    yerps = %w(param_subject param_subject_pairz param_object_pairs_or_ones_or_twos)
    nopes.each do |nope|
      expect(JSLibFigure.formal_param_is_dancers(jseval(nope))).to be(false)
    end
    yerps.each do |yerp|
      expect(JSLibFigure.formal_param_is_dancers(jseval(yerp))).to be(true)
    end
  end

  # not used
  # it 'with_prefs works' do
  #   expect(JSLibFigure.preferred_move('gyre', JSLibFigure.stub_prefs)).to eq('gyre')
  #   JSLibFigure.with_prefs(JSLibFigure.test_prefs) do
  #     expect(JSLibFigure.preferred_move('gyre', JSLibFigure.stub_prefs)).to eq('darcy')
  #   end
  #   expect(JSLibFigure.preferred_move('gyre', JSLibFigure.stub_prefs)).to eq('gyre')
  # end

  it 'preferred_move works' do
    expect(JSLibFigure.preferred_move('allemande', JSLibFigure.test_prefs)).to eq('almond')
    expect(JSLibFigure.preferred_move("Rory O'Moore", JSLibFigure.test_prefs)).to eq("Rory O'Moore")  end

  pending 'test the whole libfigure library, ha ha'
end
