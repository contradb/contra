require 'move'

class WelcomeController < ApplicationController
  def index
    @dialect_json = dialect.to_json
  end

  def search
    @dialect_json = dialect.to_json
  end

  def vue
    @dialect_json = dialect.to_json
  end

  def check_box_boss                       # CheckBoxBoss
  end
end
