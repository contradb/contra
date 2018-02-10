class DialectController < ApplicationController
  before_action :authenticate_user!

  def index
    @idioms = current_user.idioms
  end
end
