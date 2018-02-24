class IdiomsController < ApplicationController
  before_action :authenticate_user!

  def create
    @idiom = Idiom::Move.new(idiom_params)
    @idiom.user = current_user
    respond_to do |format|
      if @idiom.save
        format.html { redirect_to dialect_path, notice: 'Idiom was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @idiom }
      else
        binding.pry
        format.html { render :new }
        format.json { render json: @idiom.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def idiom_params
    puts "params = #{params.inspect}"
    params.require(:idiom_idiom).permit(:term,
                                        :substitution)
  end
end
