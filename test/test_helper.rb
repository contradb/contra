ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end


# Included per demand of https://github.com/plataformatec/devise#test-helpers
# via http://stackoverflow.com/questions/4308094/all-ruby-tests-raising-undefined-method-authenticate-for-nilnilclass
# via http://benincosa.com/?p=2965
# -dm 07-21-2015
class ActionController::TestCase
  include Devise::TestHelpers
end
