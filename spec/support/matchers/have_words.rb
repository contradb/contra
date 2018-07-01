require 'rspec/expectations'

# have_words is like have_content but it doesn't care about whitespace
RSpec::Matchers.define :have_words do |string|
  match do |page|
    re = Regexp.new(Regexp.escape(string).gsub('\ ', '(?:\s+)'))
    have_content(re).matches?(page)
  end

  failure_message do |actual|
    "expected to find #{string.inspect} in:\n#{actual.text}"
  end

  failure_message_when_negated do |actual|
    "expected not to find #{string.inspect} in:\n#{actual.text}"
  end
end
