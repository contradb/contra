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

  describe 'alias' do
    let (:do_si_do) {{"parameter_values" => ["ladles",true,360,8], "move" => "do si do"}}
    let (:see_saw) {{"parameter_values" => ["ladles",false,360,8], "move" => "do si do"}}
    let (:see_saw_2017_encoding) {{"parameter_values" => ["ladles",false,360,8], "move" => "see saw"}}

    it "knows a see saw when it sees one" do
      expect(JSLibFigure.alias(see_saw)).to eq('see saw')
    end

    it 'is cool with 2017 alias encoding scheme too' do
      expect(JSLibFigure.alias(see_saw_2017_encoding)).to eq('see saw')
    end

    it "passes 'do si do' intact" do
      expect(JSLibFigure.alias(do_si_do)).to eq('do si do')
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

  describe 'moveTermsAndSubstitutionsForSelectMenu' do
    it "bumps 'swing' to the front of the line" do
      ms = JSLibFigure.eval('moveTermsAndSubstitutionsForSelectMenu(defaultDialect)') # empty dialect
      expect(ms.first['term']).to eq('swing')
      expect(ms.first['substitution']).to eq('swing')
      expect(ms.count {|m| m['term'] == 'swing'}).to eq(2)
      expect(ms.count {|m| m['substitution'] == 'swing'}).to eq(2)
    end

    it "doesn't copy swing if it's already aliased to something in the first 5 elements" do
      ms = JSLibFigure.eval("moveTermsAndSubstitutionsForSelectMenu({moves: {swing: 'america'}, dancers: {}})").dup
      expect(ms.index {|m| (m['substitution'] == 'america') && (m['term'] == 'swing')}).to be < 5 # if this fails there are maybe more than 5 moves alphabetically lower than 'america'?
      expect(ms.count {|m| m['substitution'] == 'america'}).to eq(1)
      expect(ms.count {|m| m['term'] == 'swing'}).to eq(1)
      expect(ms.count {|m| m['substitution'] == 'swing'}).to eq(0)
    end

    it "takes '%S' out of a gyre substitution" do
      ms = JSLibFigure.eval("moveTermsAndSubstitutionsForSelectMenu(#{JSLibFigure.shoulder_round_dialect.to_json})")
      m = ms.find {|m| m['term'] == 'gyre'}
      sub = m['substitution']
      expect(sub).to_not eq('%S shoulder round')
      expect(sub).to eq('shoulder round')
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

    it 'all terms are unique' do
      h = {}
      (JSLibFigure.moves + JSLibFigure.dancers).each do |term|
        if h[term]
          raise "saw #{term.inspect} more than once"
        else
          h[term] = true
        end
      end
    end

    it 'terms contain no forbidden characters' do
      (JSLibFigure.moves + JSLibFigure.dancers).each do |term|
        # Terms are used in html-attributes, and since Rory O'Moore has a single quote
        # we have to always double quote them. So double-quote can't be used in terms.
        expect(term).to_not match(/"/)
      end
    end


    it 'slugify_move and slugifyTerm agree for all moves' do
      JSLibFigure.moves.each do |move|
        expect(JSLibFigure.slugify_move(move)).to eq(jseval("slugifyTerm(#{move.inspect})"))
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

  describe 'figure accessors' do
    it 'move'
    it 'parameter_values'
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

  it 'default_dialect' do
    expect(JSLibFigure.default_dialect).to eq({'dancers' => {}, 'moves' => {}})
  end

  describe 'dialect_for_figures' do
    let (:empty_dialect) {{'dancers' => {}, 'moves' => {}}}

    it 'does nothing to a dance that is all in-set' do
      expect(JSLibFigure.dialect_for_figures(empty_dialect,FactoryGirl.build(:box_the_gnat_contra).figures)).to eq(empty_dialect)
    end

    it "rewrites 'next neighbors' to '2nd neighbors' when '3rd neighbors' are present" do
      figures = FactoryGirl.build(:dance_with_pair, pair: '3rd neighbors').figures
      expect(JSLibFigure.dialect_for_figures(empty_dialect, figures)['dancers']).to include({'next neighbors' => '2nd neighbors'})
    end

    it "rewrites 'neighbors' to '1st neighbors' when '3rd neighbors' are present" do
      figures = FactoryGirl.build(:dance_with_pair, pair: '3rd neighbors').figures
      expect(JSLibFigure.dialect_for_figures(empty_dialect, figures)['dancers']).to include({'neighbors' => '1st neighbors'})
    end

    it "rewrites 'shadows' to '1st shadows' when '2nd shadows' are present" do
      figures = FactoryGirl.build(:dance_with_pair, pair: '2nd shadows').figures
      expect(JSLibFigure.dialect_for_figures(empty_dialect, figures)['dancers']).to include({'shadows' => '1st shadows'})
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

  it 'move_substitution works' do
    expect(JSLibFigure.move_substitution('allemande', JSLibFigure.test_dialect)).to eq('almond')
    expect(JSLibFigure.move_substitution("Rory O'Moore", JSLibFigure.test_dialect)).to eq("Rory O'Moore")
  end

  it 'dancers works' do
    expected = ['everyone',
                'gentlespoon',
                'gentlespoons',
                'ladle',
                'ladles',
                'partners',
                'neighbors',
                'ones',
                'twos',
                'same roles',
                'first corners',
                'second corners',
                'first gentlespoon',
                'first ladle',
                'second gentlespoon',
                'second ladle',
                'shadows',
                '2nd shadows',
                'prev neighbors',
                'next neighbors',
                '3rd neighbors',
                '4th neighbors']
    expect(JSLibFigure.dancers.sort).to eq(expected.sort)
  end

  describe 'string_in_dialect' do
    let (:input) {"first ladles first ladle ladles ladle"}
    let (:output) {"W1s W1 women woman"}

    it 'basically works' do
      expect(JSLibFigure.string_in_dialect("gentlespoons spoon gyre", JSLibFigure.test_dialect)).to eq("larks spoon darcy")
    end

    it 'picks longest match on ascending substitution length' do
      dialect = {"moves" => {}, "dancers" => {"ladle" => "woman", "ladles" => "women", "first ladle" => "W1"}}
      expect(JSLibFigure.string_in_dialect(input, dialect)).to eq(output)
    end

    it 'picks longest match on descending substitution length' do
      dialect = {"moves" => {}, "dancers" => {"first ladle" => "W1", "ladles" => "women", "ladle" => "woman"}}
      expect(JSLibFigure.string_in_dialect(input, dialect)).to eq(output)
    end

    it 'subs the substitution with %S filtered out' do
      dialect = JSLibFigure.shoulder_round_dialect
      expect(JSLibFigure.string_in_dialect('gyreiest gyre', dialect)).to match(' *shoulder roundiest +shoulder round')
    end
  end

  it 'move_substitution' do
    expect(JSLibFigure.move_substitution('gyre', JSLibFigure.shoulder_round_dialect)).to eq('shoulder round')
  end

  it 'moveSubstitutionWithEscape' do
    dialect_json = JSLibFigure.shoulder_round_dialect.to_json
    expect(jseval("moveSubstitutionWithEscape('gyre', #{dialect_json});")).to eq('%S shoulder round')
  end

  it 'moveSubstitutionWithoutForm' do
    mkscript = ->(substitution, article, adjective) {
      "moveSubstitutionWithoutForm('form an ocean wave', {moves: {'form an ocean wave': #{substitution.inspect}}}, #{article}, #{adjective.inspect});"
    }
    strip_form = ->(substitution, article, adjective=false) {
      jseval(mkscript.call(substitution, article, adjective)).strip
    }

    # no adjective
    expect(strip_form.call('form a long wave', true)).to eq('a long wave')
    expect(strip_form.call('form a long wave', false)).to eq('long wave')
    expect(strip_form.call('form long wave', true)).to eq('a long wave')
    expect(strip_form.call('form long wave', false)).to eq('long wave')
    expect(strip_form.call('a long wave', true)).to eq('a long wave')
    expect(strip_form.call('a long wave', false)).to eq('long wave')
    expect(strip_form.call('long wave', true)).to eq('a long wave')
    expect(strip_form.call('long wave', false)).to eq('long wave')
    expect(strip_form.call('form an undulating wave', true)).to eq('an undulating wave')
    expect(strip_form.call('form an undulating wave', false)).to eq('undulating wave')
    expect(strip_form.call('form undulating wave', true)).to eq('an undulating wave')
    expect(strip_form.call('form undulating wave', false)).to eq('undulating wave')
    expect(strip_form.call('an undulating wave', true)).to eq('an undulating wave')
    expect(strip_form.call('an undulating wave', false)).to eq('undulating wave')
    expect(strip_form.call('undulating wave', true)).to eq('an undulating wave')
    expect(strip_form.call('undulating wave', false)).to eq('undulating wave')

    # adjective 'crusty'
    expect(strip_form.call('form a long wave', true, 'crusty')).to eq('a crusty long wave')
    expect(strip_form.call('form a long wave', false, 'crusty')).to eq('crusty long wave')
    expect(strip_form.call('form long wave', true, 'crusty')).to eq('a crusty long wave')
    expect(strip_form.call('form long wave', false, 'crusty')).to eq('crusty long wave')
    expect(strip_form.call('a long wave', true, 'crusty')).to eq('a crusty long wave')
    expect(strip_form.call('a long wave', false, 'crusty')).to eq('crusty long wave')
    expect(strip_form.call('long wave', true, 'crusty')).to eq('a crusty long wave')
    expect(strip_form.call('long wave', false, 'crusty')).to eq('crusty long wave')
    expect(strip_form.call('form an undulating wave', true, 'crusty')).to eq('a crusty undulating wave')
    expect(strip_form.call('form an undulating wave', false, 'crusty')).to eq('crusty undulating wave')
    expect(strip_form.call('form undulating wave', true, 'crusty')).to eq('a crusty undulating wave')
    expect(strip_form.call('form undulating wave', false, 'crusty')).to eq('crusty undulating wave')
    expect(strip_form.call('an undulating wave', true, 'crusty')).to eq('a crusty undulating wave')
    expect(strip_form.call('an undulating wave', false, 'crusty')).to eq('crusty undulating wave')
    expect(strip_form.call('undulating wave', true, 'crusty')).to eq('a crusty undulating wave')
    expect(strip_form.call('undulating wave', false, 'crusty')).to eq('crusty undulating wave')

    # adjective 'amorphous'
    expect(strip_form.call('form a long wave', true, 'amorphous')).to eq('an amorphous long wave')
    expect(strip_form.call('form a long wave', false, 'amorphous')).to eq('amorphous long wave')
    expect(strip_form.call('form long wave', true, 'amorphous')).to eq('an amorphous long wave')
    expect(strip_form.call('form long wave', false, 'amorphous')).to eq('amorphous long wave')
    expect(strip_form.call('a long wave', true, 'amorphous')).to eq('an amorphous long wave')
    expect(strip_form.call('a long wave', false, 'amorphous')).to eq('amorphous long wave')
    expect(strip_form.call('long wave', true, 'amorphous')).to eq('an amorphous long wave')
    expect(strip_form.call('long wave', false, 'amorphous')).to eq('amorphous long wave')
    expect(strip_form.call('form an undulating wave', true, 'amorphous')).to eq('an amorphous undulating wave')
    expect(strip_form.call('form an undulating wave', false, 'amorphous')).to eq('amorphous undulating wave')
    expect(strip_form.call('form undulating wave', true, 'amorphous')).to eq('an amorphous undulating wave')
    expect(strip_form.call('form undulating wave', false, 'amorphous')).to eq('amorphous undulating wave')
    expect(strip_form.call('an undulating wave', true, 'amorphous')).to eq('an amorphous undulating wave')
    expect(strip_form.call('an undulating wave', false, 'amorphous')).to eq('amorphous undulating wave')
    expect(strip_form.call('undulating wave', true, 'amorphous')).to eq('an amorphous undulating wave')
    expect(strip_form.call('undulating wave', false, 'amorphous')).to eq('amorphous undulating wave')
  end
end
