require 'move'

class WelcomeController < ApplicationController
  def index
    @dialect_json = dialect.to_json
  end

  def search
    @dialect_json = dialect.to_json
    @tag_names_json = Tag.all.pluck(:name)
  end
end
