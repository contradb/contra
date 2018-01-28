class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :dances, dependent: :destroy
  has_many :programs, -> { order "LOWER(title)" }, dependent: :destroy
  has_many :preferences, dependent: :destroy

  validates :name, length: { in: 4..100 }  

  # prefs translates cantanerous active record objects into a single
  # nested hash, more suitible for javascript manipulation.
  # example: user.prefs =>
  # {'moves' => {'gyre' => 'darcy',
  #              'allemande' => 'almond'},
  #  'dancers' {'ladles' => 'ravens',
  #             'gentlespoons' = >'larks'}}
  def prefs
    ps = preferences
    {'moves'   => preferences_to_h(ps.select {|p| p.is_a?(MovePreference)}),
     'dancers' => preferences_to_h(ps.select {|p| p.is_a?(DancerPreference)})
    }
  end

  private
  def preferences_to_h(preferences)
    h = {}
    preferences.each {|p| h[p.term] = p.substitution}
    h
  end
end
