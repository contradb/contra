class Tag < ApplicationRecord
  has_many :duts, dependent: :destroy
  has_many :dances, through: :duts # n.b. dance may appear multiple times, consider pairing with .distinct
end
