module Move

  # mdtabs - move dance hashtables are a hash. Keys are move strings. Values are sets of dances. 
  # {move => Set{dance1, dance2,..}...}
  # The hashes are sorted by key in alphabetical order to help with display

  def self.mdtab(dances, dialect)
    mdtab = {}
    dances.each do |dance|
      dance.aliases.compact.each do |move|
        mdtab[move] ||= Set.new
        mdtab[move] << dance
      end
    end
    sort_mdtab(mdtab, dialect)
  end

  def self.following_mdtab(dances, move, dialect)
    mdtab = {}
    dances.each do |dance|
      following_moves = dance.moves_that_follow_move(move)
      following_moves.each do |following_move|
        raise 'null move' unless following_move
        mdtab[following_move] ||= Set.new
        mdtab[following_move] << dance
      end
    end
    sort_mdtab(mdtab, dialect)
  end

  def self.preceeding_mdtab(dances, move, dialect)
    mdtab = {}
    dances.each do |dance|
      preceding_moves = dance.moves_that_precede_move(move)
      preceding_moves.each do |following_move|
        raise 'null move' unless following_move
        mdtab[following_move] ||= Set.new
        mdtab[following_move] << dance
      end
    end
    sort_mdtab(mdtab, dialect)
  end

  def self.coappearing_mdtab(dances, move, dialect)
    mdtab = {}
    dances.each do |dance|
      mvs = dance.aliases.compact
      if move.in?(mvs)
        mvs.each do |related_move|
          unless related_move == move
            mdtab[related_move] ||= Set.new
            mdtab[related_move] << dance
          end
        end
      end
    end
    sort_mdtab(mdtab, dialect)
  end

  private 
  def self.sort_mdtab(mdtab, dialect)
    copy = {}
    mdtab.keys.sort_by {|move| JSLibFigure.move_substitution(move, dialect).downcase}.each {|key| copy[key] = mdtab[key]}
    copy
  end
end
