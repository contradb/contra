require 'jslibfigure'

class AddHandToChain < ActiveRecord::Migration[5.1]
  include Rails.application.routes.url_helpers

  def up
    count = 0
    changed_dance_descriptions = []
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = oldfigures.map do |figure|
        if 'chain' == JSLibFigure.move(figure)
          pvs = figure['parameter_values']
          figure.merge('parameter_values' => pvs.dup.insert(1,pvs[0] == 'ladles'))
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
