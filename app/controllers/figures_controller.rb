class FiguresController < ApplicationController

  def index
    # @dances = Dance.readable_by(current_user).alphabetical
    @moves = JSLibFigure.moves
    @move_index = Dance.move_index(Dance.readable_by(current_user))
  end

  def show
    @move = JSLibFigure.deslugify_move(params[:id])
    raise "#{params[:id].inspect} is not a move" unless @move
    @move_titleize = @move =~ /[A-Z]/ ? @move : @move.titleize # correctly passes "Rory O'Moore"
    dances = Dance.readable_by(current_user)
    move_index = Dance.move_index(dances)
    @dances = move_index[@move].to_a.sort_by(&:title)
    @preceded_by = Dance.moves_and_dances_that_precede_move(dances,@move)
    @followed_by = Dance.moves_and_dances_that_follow_move(dances,@move)
  end
end
