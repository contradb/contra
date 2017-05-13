require 'move'

class FiguresController < ApplicationController
  def index
    # @dances = Dance.readable_by(current_user).alphabetical
    @moves = JSLibFigure.moves
    @mdtab = Move.mdtab(Dance.readable_by(current_user))
  end

  def show
    @move = JSLibFigure.deslugify_move(params[:id])
    raise "#{params[:id].inspect} is not a move" unless @move
    @move_titleize = @move =~ /[A-Z]/ ? @move : @move.titleize # correctly passes "Rory O'Moore"
    @titlebar = @move_titleize
    all_dances = Dance.readable_by(current_user)
    mdtab = Move.mdtab(all_dances)
    @dances = mdtab[@move]&.sort_by(&:title) || []
    @dances_absent = (all_dances - @dances).sort_by(&:title)
    @coappearing_mdtab = Move.coappearing_mdtab(all_dances,@move)
    @preceeding_mdtab = Move.preceeding_mdtab(all_dances,@move)
    @following_mdtab = Move.following_mdtab(all_dances,@move)
    moves = JSLibFigure.moves
    idx = moves.find_index(@move)
    @prev_figure = idx.zero? ? moves.last : moves[idx-1]
    @next_figure = @move == moves.last ? moves.first : moves[idx+1]
  end
end
