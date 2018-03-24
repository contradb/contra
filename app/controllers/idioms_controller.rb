class IdiomsController < ApplicationController
  before_action :authenticate_user!

  def create
    ps = idiom_params
    t = idiom_type_from_term(ps[:term])
    @idiom = Idiom::Idiom.new(ps.merge(type: t, user: current_user))
    if @idiom.save
      render json: @idiom, status: :ok
    else
      render json: @idiom.errors, status: :unprocessable_entity
    end
  end

  def update
    @idiom = Idiom::Idiom.find(params[:id])
    @idiom or return head :unauthorized
    @idiom.user_id == current_user.id or return head :unauthorized
    respond_to do |format|
      if @idiom.update(idiom_params)
        format.json { render json: @idiom, status: :ok }
      else
        format.json { render json: @idiom.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @idiom = Idiom::Idiom.find(params[:id])
    @idiom or return head :unauthorized
    @idiom.user_id == current_user.id or return head :unauthorized
    if @idiom.destroy
      head :no_content
    else
      render json: @idiom.errors, status: :unprocessable_entity # cancelled by hooks?! this code untested
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def idiom_params
    params.require(:idiom_idiom).permit(:term, :substitution)
  end

  def idiom_type_from_term(term)
    if term.in?(JSLibFigure.moves)
      'Idiom::Move'
    elsif term.in?(JSLibFigure.dancers)
      'Idiom::Dancer'
    else
      raise('can not guess idiom type from term ' + term.inspect)
    end
  end
end
