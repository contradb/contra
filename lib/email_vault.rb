module EmailVault
  def self.get(*keys)
    Rails.application.credentials.admin&.dig(*keys) ||
      (Rails.env.test? ?
         "dummy_testing_email_vault_entry@example.com" :
         (raise "Could not get email vault entry"))
  end
end
