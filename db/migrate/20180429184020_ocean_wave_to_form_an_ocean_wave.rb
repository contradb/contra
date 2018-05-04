require 'jslibfigure'

class OceanWaveToFormAnOceanWave < ActiveRecord::Migration[5.1]
  include Rails.application.routes.url_helpers


  def down
    raise "not implemented"
  end

  def up
    count = 0
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = oldfigures.map do |figure|
        if 'ocean wave' == JSLibFigure.move(figure)
          pvs = figure['parameter_values']
          balance = pvs[0];
          beats = pvs[1];
          new_pvs = [beats === 0, 'across', balance, nil, true, nil, beats]
          figure.merge('move' => 'form an ocean wave', 'parameter_values' => new_pvs)
        else
          figure
        end
      end
      unless oldfigures == newfigures
        count += 1
        dance.record_timestamps = false
        dance.update!(figures: newfigures) 
        puts "#{dance.user.name} \t#{dance.id} \t#{dance.publish? ? '        ' : 'PRIVATE'} \t#{edit_dance_url(dance, host: 'localhost')} \t#{dance.title}"
      end
    end
    puts "#{count}/#{Dance.all.count} dances updated"
  end
end
