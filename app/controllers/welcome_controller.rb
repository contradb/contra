require 'move'

class WelcomeController < ApplicationController
  def index
    # figure link cloud
    @moves = JSLibFigure.moves
    @mdtab = Move.mdtab(Dance.readable_by(current_user))
  end
end
