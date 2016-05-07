class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :dances, -> { order "LOWER(title)" }, dependent: :destroy
  has_many :programs, -> { order "LOWER(title)" }, dependent: :destroy

  validates :name, length: { in: 4..100 }  
end
