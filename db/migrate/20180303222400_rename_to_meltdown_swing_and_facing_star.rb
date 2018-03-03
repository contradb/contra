require 'jslibfigure'

class RenameToMeltdownSwingAndFacingStar < ActiveRecord::Migration[5.1]
  def down
    raise 'too lazy to implement down'
  end
  def up
    count = 0
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = oldfigures.map do |figure|
        move = JSLibFigure.move(figure)
        if move == 'gyre meltdown'
          figure.merge('move' => 'meltdown swing')
        elsif move == 'gyre star'
          figure.merge('move' => 'facing star')
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
