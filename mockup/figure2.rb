require 'singleton'
require 'set'

class Figure
  def parameters() [] end
  MENU = {}
  def self.menu(parent=superclass)
    (MENU[parent] ||= Set.new) << self
  end
end

# Create taxonomy of figure descriptions
module WithTurn
  def parameters() super << "twirl" end
end

module WithSubject
  def parameters() super << "Subject" end
end

module WithTurn222
  include Singleton
  include WithTurn
  include WithSubject222
end

class DoSiDo < Figure
  include WithTurn222
  menu WithTurn
end
