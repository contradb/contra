module SortParser
  def self.parse(p)
    if p.match?(/\A([a-z_]+[AD])*\z/)
      a = parse_valid(p)
      a.empty? ? DEFAULT : a
    else
      raise "SortParser could not read #{p.inspect}"
    end
  end

  private
  def self.parse_valid(p)
    p.split(/(?<=[AD])/).map do |s|
      column, a_or_d = s.match(/^([a-z_]*)([AD])$/).to_a.drop(1)
      OpenStruct.new(column: column, ascending: a_or_d == 'A')
    end
  end

  DEFAULT = [OpenStruct.new(column: 'created_at', ascending: false)]
end
