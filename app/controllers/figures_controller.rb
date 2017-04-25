class FiguresController < ApplicationController

  def index
    # @dances = Dance.readable_by(current_user).alphabetical
    @moves = JSLibFigure.moves
    @move_index = Dance.move_index(Dance.readable_by(current_user))
  end

  def show
    @move = params[:id]
    raise "#{@move.inspect} is not a move" unless @move.in?(JSLibFigure.moves)
    dances = Dance.readable_by(current_user)
    move_index = Dance.move_index(dances)
    @dances = move_index[@move]
    @followed_by = Dance.moves_and_dances_that_follow_move(dances,@move)
  end
end
