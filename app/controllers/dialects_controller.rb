class DialectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @idioms = current_user.idioms
  end

  def roles
    if roles_param_lit
      Idiom::Dancer.set_roles(current_user, *roles_param_l_ls_g_gs_array)
    else
      Idiom::Dancer.clear_roles(current_user)
    end
    render json: current_user.idioms
  end

  def restore_defaults
    current_user.idioms.destroy_all
  end

  def roles_param_l_ls_g_gs_array
    params.require([:ladle, :ladles, :gentlespoon, :gentlespoons])
  end

  def roles_param_lit
    params.require(:lit).to_s == 'true'
  end
end
