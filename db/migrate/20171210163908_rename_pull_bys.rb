require 'jslibfigure'

class RenamePullBys < ActiveRecord::Migration[5.0]
  def down
    raise 'too lazy to implement down'
  end
  def up
    count = 0
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = oldfigures.map do |figure|
        move = JSLibFigure.move(figure)
        if move == 'pull by for 2'
          figure.merge('move' => 'pull by dancers')
        elsif move == 'pull by for 4'
          figure.merge('move' => 'pull by direction')
        else
          figure
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
