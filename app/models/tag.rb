class Tag < ApplicationRecord
  validates_uniqueness_of :name
  has_many :duts, dependent: :destroy
  has_many :dances, through: :duts # n.b. dance may appear multiple times, consider pairing with .distinct

  # returns a string (or nil if the db doesn't have full information)
  def documentation(me: false, other_count: 0)
    off_sentence && on_verb && on_phrase or return nil
    count = other_count + (me ? 1 : 0)
    if count.zero?
      off_sentence
    elsif other_count.zero?
      me or raise
      "you #{on_verb} #{on_phrase}"
    else
      verb = count == 1 ? on_verb_3rd_person_singular : on_verb
      the_users = ActionController::Base.helpers.pluralize(count, 'user')
      "#{the_users} #{verb} #{on_phrase}"
    end
  end

  def on_verb_3rd_person_singular
    super || on_verb
  end
end
