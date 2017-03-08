# API for talking to figures from rails, using the same logic that is used in the client-side JS code

module JSLibFigure

  def self.html(figure_ruby_hash)
    self.eval("figure_html_readonly(#{figure_ruby_hash.to_json})")
  end

  def self.beats(figure_ruby_hash)
    self.eval("figureBeats(#{figure_ruby_hash.to_json})")
  end

  def self.new
    self.eval('newFigure()')
  end

  def self.move(figure_ruby_hash)
    figure_ruby_hash['move']
  end

  def self.de_aliased_move(figure_ruby_hash)
    move_string = self.move figure_ruby_hash
    self.eval("deAliasMove(#{move_string.inspect})")
  end

  def self.teaching_name(figure_ruby_hash)
    move_string = self.move figure_ruby_hash
    self.eval("teachingName(#{move_string.inspect})")
  end

  def self.sanitize_json(figures_json_string)
    # some crap is silently stripped (because angular adds crap)
    # other crap raises an error (because we should know about it)
    parsed = JSON.parse(figures_json_string)
    case parsed
    when Array
      JSON.generate(
        parsed.map do |figure|
          f2 = {}
          pvs = figure['parameter_values']
          f2['parameter_values'] = ensure_array_of_terminal(pvs) if pvs
          move = figure['move']
          f2['move'] = ensure_string(move) if move
          note = figure['note']
          f2['note'] = ensure_string(note) if note
          f2
        end)
    else
      raise 'client submitted figures_json was not an array'
    end
  end

  # [{"formation"=>"square", "who"=>"neighbor", "beats"=>8, "balance"=>true, "move"=>"box_the_gnat"}, {"formation"=>"square", "who"=>"partner", "beats"=>8, "balance"=>true, "move"=>"swat_the_flea"}, {"formation"=>"square", "who"=>"neighbor", "beats"=>16, "balance"=>true, "move"=>"swing"}, {"formation"=>"square", "who"=>"ladles", "beats"=>8, "move"=>"allemande_right", "degrees"=>540}, {"formation"=>"square", "who"=>"partner", "beats"=>8, "move"=>"swing"}, {"formation"=>"square", "who"=>"everybody", "beats"=>8, "move"=>"right_left_through"}, {"formation"=>"square", "who"=>"ladles", "beats"=>8, "move"=>"chain", "notes"=>"look for new"}]
  # =>
  # [{"parameter_values"=>["neighbors", true, true, 8], "move"=>"box the gnat"}, {"parameter_values"=>["partners", true, false, 8], "move"=>"swat the flea"}, {"parameter_values"=>["neighbors", true, 16], "move"=>"balance and swing"}, {"parameter_values"=>["ladles", true, 540, 8], "move"=>"allemande"}, {"parameter_values"=>["partners", false, 8], "move"=>"swing"}, {"parameter_values"=>[8], "move"=>"right left through"}, {"parameter_values"=>["ladles", 8], "move"=>"chain"}, {"parameter_values"=>[0], "move"=>"progress"}]

  # [{"formation"=>"square", "who"=>"neighbor", "beats"=>8, "balance"=>true, "move"=>"box_the_gnat"}] =>
  # [{"parameter_values"=>["neighbors", true, true, 8], "move"=>"box the gnat"}]

  # require 'jslibfigure'
  # JSLibFigure.originalToJSLibFigure Dance.find(64).figures_json
  def self.originalToJSLibFigure(figures_json)
    reloadSomeJS unless @migration_context
    @migration_context.eval("originalToJSLibFigure(#{figures_json})")
    # @migration_context.eval("testConverters(#{figures_json})")
  end

  # JSLibFigure.jsLibFigureToOriginal([{"parameter_values"=>[true, 270, 8], "move"=>"circle"}].to_json).each {|x| puts x}
  # {"who"=>"everybody", "move"=>"circle_left", "beats"=>8, "formation"=>"square"}
  # => [{"who"=>"everybody", "move"=>"circle_left", "beats"=>8, "formation"=>"square"}]
  def self.jsLibFigureToOriginal(figures_json)
    reloadSomeJS unless @migration_context
    @migration_context.eval("jsLibFigureToOriginal(#{figures_json})")
  end

  # require 'jslibfigure'
  # JSLibFigure.testConverters Dance.find(64).figures_json
  # JSLibFigure.testConverters(Dance.find(64).figures_json).each {|x| puts "#{x[0]==x[1] ? 'XD' : ':('}  #{x[0]} => #{x[1]}"} 
  # JSLibFigure.testConverters(Dance.find(75).figures_json).each {|x| puts "#{x[0]==x[1] ? 'XD' : ':('}  #{x[0]} => #{x[1]}"}
  # JSLibFigure.testConverters([{"formation"=>"square", "who"=>"everybody", "beats"=>8, "move"=>"circle_left", "degrees"=>270}].to_json).each {|x| puts "#{x[0]==x[1] ? 'XD' : ':('}  #{x[0]} => #{x[1]}"}

  def self.reloadSomeJS
    @migration_context = self.new_context
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
        if JSLibFigure.testConverters(dance.figures_json).all? {|a| figureEqual a}
          print ":) "
          happy += 1
          puts "\t#{dance.id}" if verbose
        else
          print ":'( "
          sad += 1
          puts "\t#{dance.id}" if verbose
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
    x0, x1 = a
    return true if x0 == x1
    return true if x0['formation'] == nil && x0.merge('formation' => 'square') == x1
    return true if x1['formation'] == nil && x1.merge('formation' => 'square') == x0
    false
  end

  # note: migration_context corrupts the main context, rather htan
  # copying a new one. It needs to be destroyed after the migration
  # does its thing.

  private
  def self.eval(string_of_javascript)
    context.eval(string_of_javascript)
  end

  def self.context
    @context || (@context = self.new_context)
  end

  def self.new_context
    context = MiniRacer::Context.new
    %w(polyfill.js util.js move.js chooser.js param.js figure.es6 dance.js).each do |file|
      context.load(Rails.root.join('app','assets','javascripts','libfigure',file))
    end
    context
  end

  def self.ensure_array_of_terminal(ary)
    case ary
    when Array
      ary.map {|x| ensure_terminal x}
    else raise 'client submitted json was unexpectedly not an array'
    end
  end
  def self.ensure_terminal(x)
    [FalseClass, TrueClass, Fixnum, Integer, String].each do |cls|
      return x if x.instance_of? cls
    end
    raise "expecting Bool, Int, or String, but got #{x.class.name}"
  end
  def self.ensure_string(s)
    if s.instance_of?(String) then s
    else raise 'client submitted json was unexpectedly not string'
    end
  end
end
