class DutsController < ApplicationController
  def toggle
    unless current_user
      # js shouldn't let them get here unless there's something wrong
      head :forbidden
      return
    end

    dut_params_with_user = dut_params.merge(user_id: current_user.id)

    if checked?
      if Dut.find_or_create_by(dut_params_with_user)
        render json: {on: true}, status: :ok
      else
        render json: @dut.errors, status: :unprocessable_entity
      end
    else
      if Dut.find_by(dut_params_with_user)&.delete
        head :ok
      else
        head :unprocessable_entity
      end
    end
  end

  def tag_without_login
    flash[:notice] = 'Login to tag dances'
    session[:after_login] = request.env['HTTP_REFERER']
    redirect_to(new_user_session_path)
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
