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
