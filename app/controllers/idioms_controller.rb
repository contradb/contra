class IdiomsController < ApplicationController
  before_action :authenticate_user!

  def create
    @idiom = Idiom::Move.new(idiom_params)
    @idiom.user = current_user
    @idiom.type = idiom_type_from_term(@idiom.term)
    if @idiom.save
      render json: @idiom, status: :ok
    else
      # TODO worry about this branch
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
        # TODO worry about this branch
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
    else
      'Idiom::Dancer'           # need if term.in?(JSLibFigure.dancerMenuForChooser(chooser_dancers)) or something
    end
  end
end
