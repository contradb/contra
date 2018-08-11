class SearchMatch
  def initialize(first, count=1, nfigures)
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
    puts "#{(last+1) % nfigures} #{other_search_match.first}"
    puts self.inspect
    ((last+1) % nfigures == other_search_match.first)
                          .tap {|x| puts x}
  end

  def abut(other_search_match)
    abuts?(other_search_match) ? SearchMatch.new(first, count + other_search_match.count, nfigures) : nil
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
    else
      "|#{first}-#{last}%#{nfigures}|"
    end
  end

  protected
  attr_reader :arr
end
