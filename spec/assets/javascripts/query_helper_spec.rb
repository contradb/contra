

require 'rails_helper'

RSpec.describe 'query-helper' do
  it 'works' do
    expect(eval("buildFigureSentenceHelper(['figure', '*'], 'a');")).to eq('any figure')
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
