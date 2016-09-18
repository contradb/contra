module JSLibFigure
  def self.eval(string_of_javascript)
    context.eval(string_of_javascript)
  end

  private
  def self.context
    @context || (@context = self.new_context)
  end

  def self.new_context
    context = MiniRacer::Context.new
    %w(util.js move.js chooser.js param.js figure.es6 dance.js).each do |file|
      context.load(Rails.root.join('app','assets','javascripts','libfigure',file))
    end
    context
  end
end
