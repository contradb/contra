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
    self.figures = figures.map {|figure| JSLibFigure.figure_translate_text_into_dialect(figure, dialect)}
    self.preamble = JSLibFigure.string_in_dialect(preamble, dialect)
    self.notes = JSLibFigure.string_in_dialect(notes, dialect)
    self.hook = JSLibFigure.string_in_dialect(hook, dialect)
    self
  end

  # manual tool for analyzing dance changes - require 'jslibfigure'
  # there's a commented out spec for this function
  # def to_s_dump(dialect=JSLibFigure.default_dialect)
  #   buf = []
  #   attributes.each do |attr, value|
  #     if attr =~ /_id$/
  #       buf << send(attr[0,attr.length-3]).name
  #     elsif attr == 'figures_json'
  #       figures.each_with_index do |figure, i|
  #         buf << "  #{i}. #{JSLibFigure.figure_to_unsafe_text(figure, dialect)}"
  #       end
  #     elsif attr == 'publish'
  #       buf << (publish ? 'published' : 'private')
  #     elsif attr.in? %w(hook preamble notes)
  #       buf << "#{attr}: #{JSLibFigure.string_in_dialect(value, dialect).inspect}"
  #     elsif not attr.in? %w(created_at updated_at)
  #       buf << value.to_s
  #     end
  #   end
  #   buf.join("\n")
  # end
  #
  # # [589, 604, 598, 597, 599, 600, 601, 588, 602, 586, 596, 581, 576, 605].each {|id| Dance.find(id).fsnapshot('/home/dm/dances', 'new')}
  # def fsnapshot(dir, tag)
  #   File.open("#{dir}/#{id}-#{tag}.txt", 'w') {|f| f.write(to_s_dump)}
  # end
end
