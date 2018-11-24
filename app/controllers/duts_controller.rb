class DutsController < ApplicationController
  def create
    raise "TODO: Needs to redirect if not logged in" if current_user.nil?
    @dut = Dut.new(dut_params.merge(user: current_user))
    if @dut.save
      render json: @dut, status: :ok
    else
      render json: @dut.errors, status: :unprocessable_entity
    end
  end

  def destroy
    dut_id = params[:id]
    if dut_id
      Dut.find_by(id: dut_id)&.destroy!
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def dut_params
    h = {}
    # I didn't use 'permit' because contradb permit currently blows up if it finds unexpected params, and it's a global preference to get it to calm down
    [:dance_id, :tag_id].each {|s| h[s] = params.fetch(s)}
    h
  end
end
