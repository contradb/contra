require 'move'

class WelcomeController < ApplicationController
  def index
    @prefs_json = prefs.to_json
  end
end
