# abstract preference superclass
class Preference::Preference < ApplicationRecord
  belongs_to :user
  scope :moves, ->{where(type: 'Preference::Move')}
  scope :dancers, ->{where(type: 'Preference::Dancer')}
end
