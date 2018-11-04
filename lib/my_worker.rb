module MyWorker
  def self.eval(string_of_javascript)
    context.eval(string_of_javascript)
  end

  def self.reset!
    @context = nil
  end

  private
  MY_WORKER_FILES = %w(console.js MyWorker.js)

  def self.context
    @context ||= self.new_context
  end

  def self.new_context
    context = MiniRacer::Context.new
    MY_WORKER_FILES.each do |file|
      context.load(Rails.root.join('server-elm',file))
    end
    context
  end
end
