

require 'rails_helper'

RSpec.describe 'query-helper' do
  [[['figure', '*'], 'a', 'any figure'],
   [['figure', '*'], 'no', 'no figure'],
   [['figure', 'swing'], 'a', 'a swing'],
   [['figure', 'allemande'], 'a', 'an allemande'],
   [['none', ['figure', 'allemande']], 'a', 'no allemande'],
   [['none', ['or', ['figure', 'allemande'], ['figure', 'swing']]], 'a', 'no allemande and no swing'],
   [['none', ['and', ['figure', 'allemande'], ['figure', 'swing']]], 'a', 'no allemande or no swing'],
   [['none', ['then', ['figure', 'allemande'], ['figure', 'swing']]], 'a', 'no (an allemande then a swing)'],
   [['then', ['figure', 'allemande'], ['figure', 'swing']], 'a', 'an allemande then a swing'],
   [['then', ['figure', 'allemande'], ['not', ['figure', 'swing']]], 'a', /an allemande then a non +swing/],
   [['then', ['figure', 'allemande'], ['not', ['or', ['figure', 'swing'], ['figure', 'chain']]]], 'a',
    /an allemande then +not +\(a swing or a chain\)/],
   [['not', ['figure', 'swing']], 'a', /a non +swing/],
   [['not', ['or', ['figure', 'swing'], ['figure', 'chain']]], 'a', /not +\(a swing or a chain\)/],
   [["and",["then",["figure","allemande"],["figure","balance"]],["figure","box circulate"]],
    'a', '(an allemande then a balance) and a box circulate'],
   [['none', ['not', ['figure', 'swing']]], 'a', 'no non swing'],
   [['figure', '*'], 'a', 'any figure']
  ].each do |a|
    q, article, value = a
    it "buildFigureSentenceHelper(#{q.to_s}, #{article.inspect}) => #{value.inspect}" do
      expect(eval("buildFigureSentenceHelper(#{q.to_s}, #{article.inspect});")).to match(whitespice(value))
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
