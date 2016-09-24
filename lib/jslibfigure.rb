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
end
