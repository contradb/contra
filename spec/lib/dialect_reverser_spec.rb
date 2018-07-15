require 'dialect_reverser'
require 'rails_helper'

describe DialectReverser do
  let(:dialect_reverser) {DialectReverser.new(JSLibFigure.test_dialect)}

  describe '#reverse' do
    it 'works' do
      expect(dialect_reverser.reverse('larks')).to eq('gentlespoons')
      expect(dialect_reverser.reverse('first lark lark almond gentlespoon')).to eq('first gentlespoon gentlespoon allemande gentlespoon')
      expect(dialect_reverser.reverse('larksandravens larksandravens')).to eq('larksandravens larksandravens')
      expect(dialect_reverser.reverse('raven.raven-raven;raven,raven(raven)')).to eq('ladle.ladle-ladle;ladle,ladle(ladle)')
      expect(dialect_reverser.reverse('Larks and ravens.')).to eq('Gentlespoons and ladles.')
      expect(dialect_reverser.reverse('California twirl')).to eq('California twirl')
      expect(dialect_reverser.reverse('california Twirl')).to eq('california Twirl') # kinda want 'California twirl', but not enough to bloat the regexp
      expect(dialect_reverser.reverse('sliding doors')).to eq("Rory O'More")
      expect(dialect_reverser.reverse('Sliding doors')).to eq("Rory O'More")
    end

    it 'works with %S' do
      dialect_reverser = DialectReverser.new(JSLibFigure.shoulder_round_dialect)
      expect(dialect_reverser.reverse('left shoulder round')).to eq('left gyre')
    end

    it 'works with an upper case substitution' do
      dr = DialectReverser.new({'moves' => {'gentlespoons' => 'M'}, 'dancers' => {}})
      expect(dr.reverse('m')).to eq('gentlespoons')
    end
  end

  it '#make_regexp' do
    dialect = {'dancers' => {'ladles' => 'ravens'}, 'moves' => {'slice' => 'y*arn'}} # y*arn ensures regexp is properly escaped
    re = DialectReverser.new(dialect).send(:make_regexp)
    expect(re).to eq(/\b(ravens|y\*arn)\b/i)
  end


  it '#make_inverted_hash' do
    expected = {'form a short wavy line' => 'form an ocean wave',
                'do si do left shoulder' => 'see saw',
                'sliding doors' => "Rory O'More",
                'second raven' => 'second ladle',
                'second lark' => 'second gentlespoon',
                'first raven' => 'first ladle',
                'first lark' => 'first gentlespoon',
                'ravens' => 'ladles',
                'almond' => 'allemande',
                'raven' => 'ladle',
                'larks' => 'gentlespoons',
                'darcy' => 'gyre',
                'lark' => 'gentlespoon'}
    # use to_s to enforce hash order:
    got = dialect_reverser.send(:make_inverted_hash)
    expect(got).to eq(expected)
    expect(got.keys).to eq(expected.keys) # order matters
  end
end
