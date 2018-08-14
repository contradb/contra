class SearchMatch
  include Enumerable

  def initialize(first, nfigures, count: 1)
    0 <  nfigures or raise "It does not make sense to make a SearchMatch on a zero-figure dance"
    0 <= count or raise "count must be non-negative"
    0 <= first && first < nfigures or raise "first #{first} should be between 0 and nfigures #{nfigures}"
    @arr = [first, count, nfigures] # delegate to array to make hash key easy. 
  end

  def first
    @arr[0]
  end

  def last
    (first + count - 1) % nfigures
  end

  def count
    @arr[1]
  end

  def nfigures
    @arr[2]
  end

  def include?(index)
    f = first
    n = nfigures
    count.times do |i|
      return true if index == (i+f) % n
    end
    false
  end

  def each
    i = first
    n = nfigures
    count.times do
      yield i
      i += 1
      i = 0 if i >= n
    end
    self
  end

  def abuts?(other_search_match)
    (last+1) % nfigures == other_search_match.first
  end

  def abut(other_search_match)
    abuts?(other_search_match) ? SearchMatch.new(first, nfigures, count: count + other_search_match.count) : nil
  end

  def ==(x)
    self.class == x.class && arr == x.arr
  end

  alias :eql? :==

  def hash
    @arr.hash
  end

  def inspect
    if 1 == count
      "|#{first}%#{nfigures}|"
    elsif 0 == count
      "|empty@#{first}%#{nfigures}|"
    elsif (wraps = (first + count) / nfigures) >= 1
      "|#{first}#{'/'*wraps}#{last}%#{nfigures}|"
    else
      "|#{first}-#{last}%#{nfigures}|"
    end
  end

  protected
  attr_reader :arr
end
