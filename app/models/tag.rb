class Tag < ApplicationRecord
  validates_uniqueness_of :name
  has_many :duts, dependent: :destroy
  has_many :dances, through: :duts # n.b. dance may appear multiple times, consider pairing with .distinct
end
