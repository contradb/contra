

require 'rails_helper'

RSpec.describe 'query-helper' do
  [["buildFigureSentenceHelper(['figure', '*'], 'a');", 'any figure'],
   ["buildFigureSentenceHelper(['figure', '*'], 'no');", 'no figure'],
   ["buildFigureSentenceHelper(['figure', 'swing'], 'a');", 'a swing'],
   ["buildFigureSentenceHelper(['figure', 'allemande'], 'a');", 'an allemande']
  ].each do |a|
    expression, value = a
    it "#{expression} == #{value.inspect}" do
      expect(eval(expression)).to eq(value)
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
end
