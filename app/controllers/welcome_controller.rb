require 'move'

class WelcomeController < ApplicationController
  def index
    @dialect_json = dialect.to_json
  end

  def search
    @dialect_json = dialect.to_json
  end
end
