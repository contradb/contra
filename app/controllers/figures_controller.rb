require 'move'

class FiguresController < ApplicationController
  def index
    @prefs = prefs
    @move_terms_and_substitutions = JSLibFigure.move_terms_and_substitutions(@prefs)
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
    mtas = JSLibFigure.move_terms_and_substitutions(@prefs)
    idx = mtas.find_index {|m| @term == m['term']}
    @prev_move = mtas[idx-1]['term']
    @next_move = mtas[idx+1 >= mtas.length  ?  0  :  idx+1]['term']
  end

  private
  def titleize_move(string)
    string =~ /[A-Z]/ ? string : string.titleize
  end
end
