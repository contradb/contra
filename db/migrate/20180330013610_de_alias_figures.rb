require 'jslibfigure'

class DeAliasFigures < ActiveRecord::Migration[5.1]

  def down
    raise 'nope'
  end

  def up
    count = 0
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = oldfigures.map do |figure|
        move = JSLibFigure.move(figure)
        next figure unless move
        dealias = JSLibFigure.de_alias_move(move)
        alias_ = JSLibFigure.alias(figure)
        if dealias == alias_
          figure 
        else
          figure.merge('move' => dealias)
        end
      end

      unless oldfigures == newfigures
        count += 1
        dance.record_timestamps = false
        dance.update!(figures: newfigures) 
        puts "#{dance.title} (#{dance.id})"
      end
    end
    puts "#{count}/#{Dance.all.count} dances updated"
  end
end
