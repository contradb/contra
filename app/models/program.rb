class Program < ActiveRecord::Base
  belongs_to :user
  validates :title, length: { in: 4..100 }  
end
