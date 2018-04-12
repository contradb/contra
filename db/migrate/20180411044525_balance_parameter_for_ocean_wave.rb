require 'jslibfigure'

class BalanceParameterForOceanWave < ActiveRecord::Migration[5.1]
  def down
    raise "not implemented - its possible just not worth the time"
  end

  def up
    count = 0
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = oldfigures.map do |figure|
        if 'ocean wave' == JSLibFigure.move(figure)
          pvs = figure['parameter_values']
          figure.merge('parameter_values' => [false] + pvs)
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
