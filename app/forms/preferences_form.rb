class PreferencesForm
  include ActiveModel::Model
  attr_accessor :name

  def save
    valid? or return false
    # ActiveRecord::Base.transaction do
      puts 'HELLO'
      true
    # end
  end
end
