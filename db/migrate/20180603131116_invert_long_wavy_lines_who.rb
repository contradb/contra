require 'jslibfigure'

class InvertLongWavyLinesWho < ActiveRecord::Migration[5.1]
  include Rails.application.routes.url_helpers

  def down
    raise "not implemented"
  end

  def up
    count = 0
    changed_dance_descriptions = []
    Dance.all.each do |dance|
      oldfigures = dance.figures
      newfigures = oldfigures.map do |figure|
        if 'form long waves' == JSLibFigure.move(figure)
          pvs = figure['parameter_values'].dup
          who_idx = 0;
          pvs[who_idx] = invertPair(pvs[who_idx])
          figure.merge('parameter_values' => pvs)
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

  def invertPair(dancer)
    {"ladles" => "gentlespoons",
     "gentlespoons" => "ladles",
     "ones" => "twos",
     "twos" => "ones",
     "first corners" => "second corners",
     "second corners" => "first corners",
     nil => nil
    }.fetch(dancer)
  end
end
