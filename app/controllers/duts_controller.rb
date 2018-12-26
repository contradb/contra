class DutsController < ApplicationController
  def toggle
    dut_params_with_user = dut_params.merge(user: current_user)

    if checked?
      puts 'checked!'
      if Dut.find_or_create_by(dut_params_with_user)
        puts 'ok!'
        head :ok
      else
        puts 'not ok!'
        render json: @dut.errors, status: :unprocessable_entity
      end
    else
      puts 'not checked!'
      if Dut.find_by(dut_params_with_user)&.destroy
        head :ok
      else
        head :unprocessable_entity
      end
    end
  end

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
    params.permit(:dance_id, :tag_id, :checked).except(:checked)
  end

  def checked?
    !!params[:checked]
  end
end
