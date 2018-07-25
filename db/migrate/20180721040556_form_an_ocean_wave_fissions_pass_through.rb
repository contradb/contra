require 'jslibfigure'



class FormAnOceanWaveFissionsPassThrough < ActiveRecord::Migration[5.1]
  include Rails.application.routes.url_helpers

  def down
    raise "not implemented"
  end

  def up                        # also remove first parameter ('instant') of the ocean wave figure
    count = 0
    changed_dance_descriptions = []
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = []
      oldfigures.each do |figure|
        if 'form an ocean wave' == JSLibFigure.move(figure)
          pvs = figure['parameter_values']
          instant = pvs[0];
          balance = pvs[2];
          beats = pvs[-1];
          instant.in?([true,false]) or raise("instant looks wrong: #{instant.inspect}")
          balance.in?([true,false]) or raise("balance looks wrong: #{instant.inspect}")
          beats.in?((0..8).to_a) or raise("beats looks wrong: #{beats.inspect}")
          if instant
            newfigures << figure.merge('parameter_values' => pvs.drop(1))
          else
            new_wave_beats = balance ? 4 : 0
            pass_through_beats = beats - new_wave_beats
            pass_through_beats >= 0 or raise("Really low number of beats #{pass_through_beats} - panic! #{figure.inspect} #{dance.title}")
            pass_through_beats != 0 or puts("Really low number of beats #{pass_through_beats} - panic! #{figure.inspect} #{dance.title}")
            newfigures << {'move' => 'pass through', 'parameter_values' => ['across', true, pass_through_beats]}
            newfigures << figure.merge('parameter_values' => [*pvs.take(pvs.length-1).drop(1), new_wave_beats])
          end
        else
          newfigures << figure
        end
      end
      unless oldfigures == newfigures
        count += 1
        dance.record_timestamps = false
        dance.update!(figures: newfigures) 
        changed_dance_descriptions << "- [ ] #{dance.user.name} [#{dance.title}](#{edit_dance_url(dance, host: 'localhost')}) \t#{dance.publish? ? '' : '*private*'}"
      end
    end
    puts changed_dance_descriptions.sort
    puts "#{count}/#{Dance.all.count} dances updated"
  end
end
