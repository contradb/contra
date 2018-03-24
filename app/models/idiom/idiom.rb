# abstract idiom superclass
class Idiom::Idiom < ApplicationRecord
  belongs_to :user

  validates :term, presence: true
  validates :substitution, presence: true
  validates :type, presence: true
  validates :user, presence: true
end
