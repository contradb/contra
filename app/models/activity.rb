class Activity < ApplicationRecord
  belongs_to :program, inverse_of: :activities
  belongs_to :dance, optional: true
end
