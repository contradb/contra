class DialectController < ApplicationController
  before_action :authenticate_user!

  def index
    @idioms = current_user.idioms
  end

  def restore_defaults
    current_user.idioms.destroy_all
  end
end
