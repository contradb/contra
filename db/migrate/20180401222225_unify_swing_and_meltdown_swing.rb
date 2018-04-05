require 'jslibfigure'

class UnifySwingAndMeltdownSwing < ActiveRecord::Migration[5.1]
  def down
    raise "not implemented - its possible just not worth the time"
  end

  def up
    count = 0
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = oldfigures.map do |figure|
        move = JSLibFigure.move(figure)
        pvs = JSLibFigure.parameter_values(figure).clone
        if move == 'swing'
          pvs[1] == 'false' and raise "string 'false' looks suspicious - refusing to treat it as truthy"
          pvs[1] = pvs[1] ? 'balance' : 'none'
          figure.merge('parameter_values' => pvs)
        elsif move == 'meltdown swing'
          pvs[1,0] = 'meltdown'
          figure.merge('parameter_values' => pvs, 'move' => 'swing')
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
