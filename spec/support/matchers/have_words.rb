require 'rspec/expectations'

# have_words is like have_content but it glosses over \t and \n
# inserted by capybara 3. It only accepts a string, not a regexp.
RSpec::Matchers.define :have_words do |string|
  match do |page|
    re = Regexp.new(Regexp.escape(string).gsub(/(\\ )+/, '(?:\s+)'))
    have_content(re).matches?(page)
  end

  match_when_negated do |page|
    re = Regexp.new(Regexp.escape(string).gsub(/(\\ )+/, '(?:\s+)'))
    have_no_content(re).matches?(page)
  end

  failure_message do |actual|
    "expected to find #{string.inspect} in:\n#{actual.text}"
  end

  failure_message_when_negated do |actual|
    "expected not to find #{string.inspect} in:\n#{actual.text}"
  end
end
