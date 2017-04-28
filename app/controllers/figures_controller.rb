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
    dances = Dance.readable_by(current_user)
    mdtab = Move.mdtab(dances)
    @dances = mdtab[@move].sort_by(&:title)
    @dances_absent = (dances - mdtab[@move].to_a).sort_by(&:title)
    @coappearing_mdtab = Move.coappearing_mdtab(dances,@move)
    @preceeding_mdtab = Move.preceeding_mdtab(dances,@move)
    @following_mdtab = Move.following_mdtab(dances,@move)
  end
end
