ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# make server run on port 3333 instead of 3000
# http://stackoverflow.com/questions/18103316/how-to-change-default-port-of-a-rails-4-app

require 'rails/commands/server'

module DefaultOptions
  def default_options
    super.merge!(Port: 3333)
  end
end

Rails::Server.send(:prepend, DefaultOptions)
