

require 'rails_helper'

RSpec.describe 'query-helper' do
  describe 'sentence' do
    [[['figure', '*'], 'a', 'any figure'],
     [['figure', '*'], 'no', 'no figure'],
     [['figure', 'swing'], 'a', 'a swing'],
     [['figure', 'allemande'], 'a', 'an allemande'],
     [['figure', 'circle'], 'a', /a circle/],
     [['figure', 'circle', true, 360, 8], 'a', 'a circle left 4 places'],
     [['no', ['figure', 'allemande']], 'a', 'no allemande'],
     [['no', ['or', ['figure', 'allemande'], ['figure', 'swing']]], 'a', 'no allemande and no swing'],
     [['no', ['and', ['figure', 'allemande'], ['figure', 'swing']]], 'a', 'no allemande or no swing'],
     [['no', ['then', ['figure', 'allemande'], ['figure', 'swing']]], 'a', 'no (an allemande then a swing)'],
     [['then', ['figure', 'allemande'], ['figure', 'swing']], 'a', 'an allemande then a swing'],
     [['then', ['figure', 'allemande'], ['~', ['figure', 'swing']]], 'a', /an allemande then a non +swing/],
     [['then', ['figure', 'allemande'], ['~', ['or', ['figure', 'swing'], ['figure', 'chain']]]], 'a',
      /an allemande then +~ +\(a swing or a chain\)/],
     [['~', ['figure', 'swing']], 'a', /a non +swing/],
     [['~', ['or', ['figure', 'swing'], ['figure', 'chain']]], 'a', /~ +\(a swing or a chain\)/],
     [["and",["then",["figure","allemande"],["figure","balance"]],["figure","box circulate"]],
      'a', '(an allemande then a balance) and a box circulate'],
     [['no', ['~', ['figure', 'swing']]], 'a', 'no non swing'],
     [['figure', '*'], 'a', 'any figure'],
     [['formation', 'improper'], 'a', 'an improper formation'],
     [['and', ['figure', 'swing'], ['formation', 'improper']], 'a', 'a swing and an improper formation'],
     [['and', ['formation', 'improper'], ['figure', 'swing']], 'a', 'an improper formation and a swing'],
    ].each do |a|
      q, article, value = a
      it "buildFigureSentenceHelper(#{q.to_s}, #{article.inspect}, defaultDialect) => #{value.inspect}" do
        expect(eval("buildFigureSentenceHelper(#{q.to_s}, #{article.inspect}, defaultDialect);")).to match(whitespice(value))
      end
    end
  end

  private
  def eval(string_of_javascript)
    context.eval(string_of_javascript)
  end

  def context
    @context || (@context = new_context)
  end

  def new_context
    context = MiniRacer::Context.new
    JSLibFigure::JSLIBFIGURE_FILES.each do |file|
      context.load(Rails.root.join('app','assets','javascripts','libfigure',file))
    end
    context.load(Rails.root.join('app','assets','javascripts','query_helper.js'))
    context
  end

  def whitespice(x) 
    case x
    when Regexp; x
    when String;
      quote = Regexp.escape(x).to_s
      /\A\s*#{quote.gsub('\ ','\s+')}\s*\z/
    else raise 'unexpected type in whitespice'
    end
  end
end
