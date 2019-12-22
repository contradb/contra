module SortParser
  def self.parse(p)
    raise "unpossible" if p == ['title']
    if p.match?(/\A((?:title|choreographer_name|hook|formation|user_name|created_at|updated_at|publish)[AD])*\z/)
      a = parse_valid(p)
      a.empty? ? DEFAULT : a
    else
      raise "SortParser could not read #{p.inspect}"
    end
  end
  # "title",
  # {hook: :desc},
  # Choreographer.arel_table[:name].desc
  private
  def self.parse_valid(p)
    p.split(/(?<=[AD])/).map do |s|
      column, a_or_d = s.match(/^([a-z_]*)([AD])$/).to_a.drop(1)
      is_ascending = a_or_d == 'A'
      case column
      when 'choreographer_name'
        is_ascending ? 'choreographers.name' : Choreographer.arel_table[:name].desc
      when 'user_name'
        is_ascending ? 'users.name' : User.arel_table[:name].desc
      when 'formation'
        is_ascending ? 'start_type' : {'start_type' => :desc}
      when 'created_at', 'updated_at'
        is_ascending ? "dances.#{column}" : Dance.arel_table[column.to_sym].desc
      else
        # is_ascending ? User.arel_table[:name].lower.asc : User.arel_table[:name].lower.desc

        is_ascending ? column : {column => :desc}
      end
    end
  end

  DEFAULT = [{created_at: :desc}]
end
