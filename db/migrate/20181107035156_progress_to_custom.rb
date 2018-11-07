require 'jslibfigure'

# note that this requires progress to still be a figure to run:
# defineFigure("progress", [param_beats_0]);

class ProgressToCustom < ActiveRecord::Migration[5.1]
  include Rails.application.routes.url_helpers

  def up
    count = 0
    changed_dance_descriptions = []
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = oldfigures.map do |figure|
        if 'progress' == JSLibFigure.move(figure)
          pvs = figure['parameter_values'].dup
          pvs.unshift(JSLibFigure.figure_to_unsafe_text(figure, JSLibFigure.default_dialect))
          figure.merge('move' => 'custom', 'parameter_values' => pvs, note: '')
        else
          figure
        end
      end
      unless oldfigures == newfigures
        count += 1
        dance.record_timestamps = false
        dance.update!(figures: newfigures)
        changed_dance_descriptions << "- [ ] #{dance.user.obfuscated_name} [#{dance.title}](#{dance_url(dance, host: 'contradb.com')}) #{dance.user.moderation unless dance.user.moderation_unknown?} #{dance.publish? ? '' : '*private*'}"
      end
    end
    puts changed_dance_descriptions.sort
    puts "#{count}/#{Dance.all.count} dances updated"
  end
end
