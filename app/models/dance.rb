class Dance < ActiveRecord::Base
  belongs_to :user
  belongs_to :choreographer
end
