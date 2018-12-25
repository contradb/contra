class Tag < ApplicationRecord
  validates_uniqueness_of :name
  has_many :duts, dependent: :destroy
  has_many :dances, through: :duts # n.b. dance may appear multiple times, consider pairing with .distinct

  def documentation(me: false, other_count: 0)
    count = other_count + (me ? 1 : 0)
    if count.zero?
      off_sentence
    elsif other_count.zero?
      me or raise
      "you #{on_phrase}"
    else
      "#{ActionController::Base.helpers.pluralize(count, 'user')} #{on_phrase}"

    end
  end
end
