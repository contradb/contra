require 'jslibfigure'

# reopen class
module JSLibFigure
  def self.originalToJSLibFigure(figures_json)
    reloadSomeJS unless @migration_context
    @migration_context.eval("originalToJSLibFigure(#{figures_json})")
    # @migration_context.eval("testConverters(#{figures_json})")
  end

  def self.jsLibFigureToOriginal(figures_json)
    reloadSomeJS unless @migration_context
    @migration_context.eval("jsLibFigureToOriginal(#{figures_json})")
  end


  def self.reloadSomeJS
    @migration_context = self.send(:new_context)
    @migration_context.load(Rails.root.join('lib','assets','javascripts','libfigure-migration.js'))
  end

  def self.testConverters(figures_json)
    reloadSomeJS unless @migration_context
    @migration_context.eval("testConverters(#{figures_json})")
  end

  def self.migrationDashboard(verbose: false)
    happy = sad = dead = 0;
    Dance.all.each do |dance|
      begin
        if JSLibFigure.testConverters(dance.figures_json).all? {|a| figureEqual(a)}
          print ":) "
          happy += 1
          puts "\t#{dance.id}" if verbose
        else
          print ":'( "
          sad += 1
          if verbose
            first_fail = JSLibFigure.testConverters(dance.figures_json).find {|a| ! figureEqual a}
            a,b = hashdiff first_fail
            puts "\t#{dance.id}\t#{first_fail.dig(0,'move')} #{a} /= #{b}"
          end
        end
      rescue MiniRacer::RuntimeError => e
        print ":O "
        dead +=1
        puts "\t#{dance.id}\t#{e}" if verbose
      end
    end
    puts
    puts ":) #{happy}   :'( #{sad}   :O #{dead}"
  end

  def self.figureEqual(a)
    x0, x1 = a.map {|x|         # strip nil balances
      if x.key?('balance') && !x['balance'] then hash_remove_key(x, 'balance') else x end
    }.map {|x|                  # strip empty notes
      if x['notes'] == '' then hash_remove_key(x, 'notes') else x end
    }.map {|x|                  # default formation
      if x['formation'].present? then x else x.merge({'formation' => 'square'}) end
    }.map {|x|
      if x['move'] == 'star_promenade' && x['who'] == 'gentlespoons' then x.merge('who' => 'everybody') else x end
    }.map {|x|
      if x['move'] == 'butterfly_whirl' then hash_remove_key(hash_remove_key(x, 'degrees'), 'who') else x end
    }
    return x0 == x1
  end

  # note: migration_context corrupts the main context, rather htan
  # copying a new one. It needs to be destroyed after the migration
  # does its thing.
  private
    # recursively step through two hashes and find which elements are different
  # input: array of two hashes
  # output: array of two hashes where values for each key are unique
  def self.hashdiff(a)
    x,y = a
    return a if x.empty?
    key, x1_value = x.first
    same = y.key?(key) &&  x1_value == y[key]
    xx = x.clone
    yy = y.clone
    xx.delete key
    yy.delete key
    if same
      return hashdiff [xx,yy]
    else
      y1_value = y[key]
      x2, y2 = hashdiff [xx,yy]
      return [x2.merge(key => x1_value), y.key?(key) ? y2.merge(key => y1_value) : y2]
    end
  end

  def self.hash_remove_key(hash, key)
    hash.clone.tap {|h| h.delete(key)}
  end
end

class ToJslibfigure < ActiveRecord::Migration
  def up
    Dance.all.each do |dance|
      dance.update(figures_json: JSLibFigure.originalToJSLibFigure(dance.figures_json).to_json)
    end
  end
  def down
    Dance.all.each do |dance|
      dance.update(figures_json: JSLibFigure.jsLibFigureToOriginal(dance.figures_json).to_json)
    end
  end
end
