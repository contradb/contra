class PreferencesForm
  include ActiveModel::Model
  attr_accessor :name

  # has_many 'Preference::Preferences'
  # accepts_nested_attributes_for 'Preference::Preferences'

  def x_attributes=(attributes)
    binding.pry
  end

  def xs
    @xs ||= [Preference::Move.new(term: 'gyre', substitution: 'darcy'), Preference::Dancer.new(term: 'ladles', substitution: 'ravens')]
  end


  def p0
    @preference0 || Preference::Move.new
  end
  def p0=(value)
    @preference0 = value
  end

  def save
    valid? or return false
    # ActiveRecord::Base.transaction do
      puts 'HELLO'
      true
    # end
  end
end
