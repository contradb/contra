class Dut < ApplicationRecord
  belongs_to :dance
  belongs_to :user
  belongs_to :tag
  validates_uniqueness_of :user, scope: [:dance, :tag]
end
