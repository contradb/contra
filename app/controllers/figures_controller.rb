class FiguresController < ApplicationController

  def index
    # @dances = Dance.readable_by(current_user).alphabetical
    @moves = JSLibFigure.moves
    @move_index = Dance.move_index(Dance.readable_by(current_user))
  end

  def show
  end
end
