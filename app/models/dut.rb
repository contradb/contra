class Dut < ApplicationRecord
  belongs_to :dance
  belongs_to :user
  belongs_to :tag
  validates :dance, presence: true
  validates :user, presence: true
  validates :tag, presence: true
  validates_uniqueness_of :user, scope: [:dance, :tag]
end
