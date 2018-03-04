class DialectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @idioms = current_user.idioms
  end

  def roles
    Idiom::Dancer.set_roles(current_user, *roles_param_l_ls_g_gs_array)
    render json: current_user.idioms
  end

  def restore_defaults
    current_user.idioms.destroy_all
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def roles_param_l_ls_g_gs_array
    params.require([:ladle, :ladles, :gentlespoon, :gentlespoons])
  end
end
