require 'jslibfigure'

class EmptyFigureToStandStill < ActiveRecord::Migration[5.1]
  include Rails.application.routes.url_helpers

  def up
    count = 0
    changed_dance_descriptions = []
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = oldfigures.map do |figure|
        unless JSLibFigure.move(figure) && JSLibFigure.parameter_values(figure)
          figure.merge('move' => 'stand still', 'parameter_values' => [8])
        else
          figure
        end
      end
      unless oldfigures == newfigures
        count += 1
        dance.record_timestamps = false
        dance.update!(figures: newfigures) 
        changed_dance_descriptions << "- [ ] #{dance.user.name} [#{dance.title}](#{dance_url(dance, host: 'contradb.com')}) #{dance.user.moderation unless dance.user.moderation_unknown?} #{dance.publish? ? '' : '*private*'}"
      end
    end
    puts changed_dance_descriptions.sort
    puts "#{count}/#{Dance.all.count} dances updated"
  end
end
