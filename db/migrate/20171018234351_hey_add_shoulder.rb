require 'jslibfigure'

class HeyAddShoulder < ActiveRecord::Migration
  def down
    raise 'too lazy to implement down'
  end
  def up
    count = 0
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = oldfigures.map do |figure|
        move = JSLibFigure.move(figure)
        oldpvs = figure['parameter_values']
        if move == 'hey'
          newpvs = oldpvs.clone.unshift(oldpvs.first)
          newpvs[1] = true
          figure.merge('parameter_values' => newpvs)
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
