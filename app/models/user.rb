class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :dances, dependent: :destroy
  has_many :programs, -> { order "LOWER(title)" }, dependent: :destroy
  has_many :idioms, dependent: :destroy, class_name: 'Idiom::Idiom'

  validates :name, length: { in: 4..100 }  

  enum moderation: %w(unknown hermit owner collaborative), _prefix: true

  # dialect translates cantanerous active record objects into a single
  # nested hash, more suitible for javascript manipulation.
  # example: user.dialect =>
  # {'moves' => {'gyre' => 'darcy',
  #              'allemande' => 'almond'},
  #  'dancers' {'ladles' => 'ravens',
  #             'gentlespoons' = >'larks'}}
  def dialect
    is = idioms
    {'moves'   => idioms_to_h(is.select {|i| i.is_a?(Idiom::Move)}),
     'dancers' => idioms_to_h(is.select {|i| i.is_a?(Idiom::Dancer)})
    }
  end

  private
  def idioms_to_h(idioms)
    h = {}
    idioms.each {|idiom| h[idiom.term] = idiom.substitution}
    h
  end
end
