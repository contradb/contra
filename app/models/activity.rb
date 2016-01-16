class Activity < ActiveRecord::Base
  belongs_to :program
  belongs_to :dance
end
