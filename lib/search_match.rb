class SearchMatch
  def initialize(first, nfigures, count: 1)
    @arr = [first, count, nfigures]
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
    elsif (wraps = (first + count) / nfigures) >= 1
      "|#{first}#{'/'*wraps}#{last}%#{nfigures}|"
    else
      "|#{first}-#{last}%#{nfigures}|"
    end
  end

  protected
  attr_reader :arr
end
