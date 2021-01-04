module EmailVault
  def self.get(*keys)
    value = Rails.application.credentials.admin&.dig(*keys)
    return value if value
    if Rails.env.test? || Rails.env.development?
      warn "Rails.application.credentails not correctly configured. You can put it in config/master.key or $RAILS_MASTER_KEY." if Rails.env.development?
      return "dummy_testing_email_vault_entry@example.com"
    else
      raise "Could not get email vault entry"
    end
  end
end
