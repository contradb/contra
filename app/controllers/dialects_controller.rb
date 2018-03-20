class DialectsController < ApplicationController
  before_action :authenticate_user!

  def index
    @idioms = current_user.idioms
  end

  def roles
    Idiom::Dancer.set_roles(current_user, *roles_param_l_ls_g_gs_array)
    render json: current_user.idioms
  end

  def roles_restore_defaults
    Idiom::Dancer.clear_roles(current_user)
    render json: current_user.idioms
  end

  def gyre
    idiom = current_user.idioms.find_or_initialize_by(user_id: current_user.id, type: Idiom::Move.to_s, term: 'gyre')
    idiom.update!(substitution: gyre_substitution_param)
    render json: current_user.idioms
  end

  def restore_defaults
    current_user.idioms.destroy_all
  end

  def roles_param_l_ls_g_gs_array
    params.require([:ladle, :ladles, :gentlespoon, :gentlespoons])
  end

  def gyre_substitution_param
    params.require(:substitution)
  end
end
