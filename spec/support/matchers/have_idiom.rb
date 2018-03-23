require 'rspec/expectations'

RSpec::Matchers.define :have_idiom do |idiom|
  match do |page|
    have_idiom_with(idiom.term, idiom.substitution).matches?(page)
  end
end
