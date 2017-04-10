class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :dances, -> { order "LOWER(title)" }, dependent: :destroy
  has_many :programs, -> { order "LOWER(title)" }, dependent: :destroy

  validates :name, length: { in: 4..100 }  

  # TODO I wish this was called more. There are still at ton of places that just check id==1 -dm 04-09-2017
  def is_admin?
    id == 1
  end
end
