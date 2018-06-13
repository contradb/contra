# service object which translates strings full of dialect substitutions back into terms

class DialectReverser
  attr_reader :dialect

  def initialize(dialect)
    @dialect = dialect
    raise 'dialect is not one-to-one' unless check_one_to_one
    @inverted_hash = make_inverted_hash
    @regexp = make_regexp
  end

  def reverse(string)           # really string-or-falsey
    string ? string.gsub(regexp, inverted_hash) : string
  end

  private 
  attr_reader :regexp
  attr_reader :inverted_hash


  def check_one_to_one
    true
  end

  def make_inverted_hash
    alist = dialect.fetch('moves').to_a + dialect.fetch('dancers').to_a
    alist = alist.sort do |term_sub_a, term_sub_b|
      a = term_sub_a[1]
      b = term_sub_b[1]
      diff = b.length - a.length
      diff.zero? ? b <=> a : diff
    end
    alist.map(&:reverse).to_h
  end

  def make_regexp
    /#{inverted_hash.keys.map {|s| Regexp.escape(s)}.join('|')}/i
  end
end
