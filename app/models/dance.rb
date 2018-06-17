require 'json'

class Dance < ApplicationRecord
  belongs_to :user
  belongs_to :choreographer
  validates :title, length: { in: 3..100 }
  validates :start_type, length: { in: 1..100 }
  accepts_nested_attributes_for :choreographer

  scope :alphabetical, ->() { order "LOWER(title)" }
  scope :readable_by, ->(user=nil) {
    if user.nil?
      where(publish: true)
    elsif user.admin?
      all
    else
      where(publish: true).or(where(user_id: user.id))
    end
  }

  def readable?(user=nil)
    publish || user_id == user&.id || user&.admin? || false
  end

  # beware of nils in the array for empty moves
  def aliases
    figures.map {|f| JSLibFigure.move(f) && JSLibFigure.alias(f)}
  end

  def figures
    @figures ||= JSON.parse figures_json
  end

  def figures=(value)
    self.figures_json = JSON.generate(value)
    @figures = value
  end

  def figures_json=(value)
    @figures = nil              # invalidate cache
    super
  end

  # eases form defaulting:
  def choreographer_name
    choreographer ? choreographer.name : ""
  end

  def moves_that_follow_move(move)
    followers = Set.new
    mvs = aliases.compact
    mvs.each_with_index do |m,index|
      previous_move_matches = move == mvs[index-1] # yes, index-1 is occassionaly -1, that's great!
      followers << m if previous_move_matches
    end
    followers
  end

  def moves_that_precede_move(move)
    preceders = Set.new
    mvs = aliases.compact
    mvs.each_with_index do |m,index|
      move_matches = move == m
      preceders << mvs[index-1] if move_matches # index-1 is occassionally -1, that's great!
    end
    preceders
  end

  HOOK_MAX_LENGTH = 50

  # modify dance text in-place to be in dialect (model shouldn't be saved in this state, it's for setting up forms)
  def set_text_to_dialect(dialect)
    self.figures = figures.map {|figure| JSLibFigure.figure_with_text_in_dialect(figure, dialect)}
    self.preamble = JSLibFigure.string_in_dialect(preamble, dialect)
    self.notes = JSLibFigure.string_in_dialect(notes, dialect)
    self.hook = JSLibFigure.string_in_dialect(hook, dialect)
    self
  end
end
