class PreferencesForm
  include ActiveModel::Model
  attr_accessor :user

  def initialize(params)
    # force @user initialization before preferences_attributes=, which is called by super
    @user = params[:user] or raise('Missing user parameter')
    super(params)
  end

  def preferences
    @preferences ||= user.preferences
  end

  def preferences_attributes=(attr_hash)
    attr_hash.keys.all? {|k| k.is_a?(String) && k =~ /\A[0-9]+\z/} or raise('expected attr_hash to have keys of present strings of digits')
    attr_hash.values.all? {|v| v.is_a?(Hash)} or raise('expected attr_hash to have values of hashes')
    @preferences = attr_hash.values.map do |preference_attrs|
      p = preferences.find_or_initialize_by(id: preference_attrs[:id])
      p.assign_attributes(preference_attrs.except(:id, :user_id))
      p
    end
  end

  def save
    if invalid?
      false
    else
      ActiveRecord::Base.transaction do
        preferences.each(&:save)
        true
      end
    end
  end
end
