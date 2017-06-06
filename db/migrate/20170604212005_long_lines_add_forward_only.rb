require 'jslibfigure'

class LongLinesAddForwardOnly < ActiveRecord::Migration
  def up
    count = 0
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = oldfigures.map do |figure|
        move = JSLibFigure.move(figure)
        if move == 'long lines'
          newpvs = figure['parameter_values'].clone.unshift(true)
          figure.merge('parameter_values' => newpvs)
        elsif move == 'long lines forward only'
          newpvs = figure['parameter_values'].clone.unshift(false)
          figure.merge('move' => 'long lines', 'parameter_values' => newpvs)
        else
          figure
        end
      end
      unless oldfigures == newfigures
        count += 1
        puts "#{dance.title} (#{dance.id})"
        dance.update!(figures: newfigures) 
      end
    end
    puts "#{count}/#{Dance.all.count} dances updated"
  end
end
