require 'move'

class FiguresController < ApplicationController
  def index
    @prefs = prefs
    @move_preferences = JSLibFigure.moves2(@prefs)
    @mdtab = Move.mdtab(Dance.readable_by(current_user), @prefs)
  end

  def show
    @term = JSLibFigure.deslugify_move(params[:id])
    raise "#{params[:id].inspect} is not a move" unless @term
    @prefs = prefs
    @substitution = JSLibFigure.preferred_move(@term, @prefs)
    @move_titleize = titleize_move(@substitution)
    @titlebar = @move_titleize
    all_dances = Dance.readable_by(current_user)
    mdtab = Move.mdtab(all_dances, @prefs)
    @dances = mdtab.fetch(@term, []).sort_by(&:title)
    @dances_absent = (all_dances - @dances).sort_by(&:title)
    @coappearing_mdtab = Move.coappearing_mdtab(all_dances, @term, @prefs)
    @preceeding_mdtab = Move.preceeding_mdtab(all_dances, @term, @prefs)
    @following_mdtab = Move.following_mdtab(all_dances, @term, @prefs)
    moves = JSLibFigure.moves2(@prefs)
    idx = moves.find_index {|m| @term == m['value']}
    @prev_move = moves[idx-1]['value']
    @next_move = moves[idx+1 >= moves.length  ?  0  :  idx+1]['value']
  end

  private
  def prefs
    current_user&.prefs || JSLibFigure.stub_prefs
  end

  def titleize_move(string)
    string =~ /[A-Z]/ ? string : string.titleize
  end
end
