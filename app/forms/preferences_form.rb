class PreferencesForm
  include ActiveModel::Model
  attr_accessor :user

  def initialize(params)
    # force @user initialization before xs_attributes=, which is called by super
    @user = params[:user] or raise('Missing user parameter')
    super(params)
  end

  def xs
    # TODO: load from DB
    # TODO: rename 'xs' to 'preferences'
    @xs ||= [Preference::Move.new(term: 'gyre', substitution: 'darcy'), Preference::Dancer.new(term: 'ladles', substitution: 'ravens')]
  end

  def xs_attributes=(attr_hash)
    attr_hash.keys.all? {|k| k.is_a?(String) && k =~ /\A[0-9]+\z/} or raise('expected attr_hash to have keys of present strings of digits')
    attr_hash.values.all? {|v| v.is_a?(Hash)} or raise('expected attr_hash to have values of hashes')
    @xs = attr_hash.values.map do |preference_attrs|
      Preference::Preference.new(preference_attrs.merge(user_id: user.id))
    end
  end

  def save
    valid? or return false
    # ActiveRecord::Base.transaction do
      true
    # end
  end
end
