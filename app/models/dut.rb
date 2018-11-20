class Dut < ApplicationRecord
  belongs_to :dance
  belongs_to :user
  belongs_to :tag
end
