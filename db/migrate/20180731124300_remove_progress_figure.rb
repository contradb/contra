require 'jslibfigure'

class RemoveProgressFigure < ActiveRecord::Migration[5.1]
  include Rails.application.routes.url_helpers

  def change
    count = 0
    changed_dance_descriptions = []
    cowardly_refusing_to_change_dance_descriptions = []
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = []
      oldfigures.each_with_index do |figure, index|
        next_figure = oldfigures[(index+1) % oldfigures.length]
        if replaceable_progression?(next_figure)
          newfigures << figure.merge('progression' => 1)
        elsif replaceable_progression?(figure)
          ;
        else
          cowardly_refusing_to_change_dance_descriptions << remember_dance_string(dance) if 'progress' == JSLibFigure.move(figure)
          newfigures << figure
        end
      end
      unless oldfigures == newfigures
        count += 1
        dance.record_timestamps = false
        dance.update!(figures: newfigures)
        changed_dance_descriptions << remember_dance_string(dance)
      end
    end
    puts "== Dances still with progressions"
    puts cowardly_refusing_to_change_dance_descriptions.uniq.sort
    puts "== Dances changed"
    puts changed_dance_descriptions.sort
    puts "#{count}/#{Dance.all.count} dances updated"
  end

  def replaceable_progression?(f)
    'progress' == JSLibFigure.move(f) && JSLibFigure.note(f).blank?
  end

  def remember_dance_string(dance)
    "- [ ] #{dance.user.name} [#{dance.title}](#{dance_url(dance, host: 'contradb.com')}) #{dance.user.moderation unless dance.user.moderation_unknown?} #{dance.publish? ? '' : '*private*'}"
  end
end
