class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :dances, dependent: :destroy
  has_many :programs, -> { order "LOWER(title)" }, dependent: :destroy
  has_many :preferences, dependent: :destroy, class_name: 'Preference::Preference'

  validates :name, length: { in: 4..100 }  

  # dialect translates cantanerous active record objects into a single
  # nested hash, more suitible for javascript manipulation.
  # example: user.dialect =>
  # {'moves' => {'gyre' => 'darcy',
  #              'allemande' => 'almond'},
  #  'dancers' {'ladles' => 'ravens',
  #             'gentlespoons' = >'larks'}}
  def dialect
    ps = preferences
    {'moves'   => preferences_to_h(ps.select {|p| p.is_a?(Preference::Move)}),
     'dancers' => preferences_to_h(ps.select {|p| p.is_a?(Preference::Dancer)})
    }
  end

  private
  def preferences_to_h(preferences)
    h = {}
    preferences.each {|p| h[p.term] = p.substitution}
    h
  end
end
