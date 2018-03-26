require 'jslibfigure'

class MoreParametersForDownTheHall < ActiveRecord::Migration[5.1]
  def down
    raise "not implemented - its possible just not worth the time"
  end

  def up
    count = 0
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = oldfigures.map do |figure|
        if JSLibFigure.move(figure).in? ['down the hall', 'up the hall']
          pvs = figure['parameter_values'].clone
          pvs[1] = 'turn-couple' if pvs[1] == 'turn-couples'
          figure.merge('parameter_values' => ['everyone', 'all'] + pvs)
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
