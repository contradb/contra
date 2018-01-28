# abstract preference superclass
class Preference::Preference < ApplicationRecord
  belongs_to :user
end
