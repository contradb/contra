class UsersController < ApplicationController
  before_action :set_user, except: [:index, :update_preferences]
  before_action :authenticate_user!, except: [:index, :show]


  def index
    @users = User.all.order "LOWER(name)"
    @show_newsletter_mailto = current_user&.admin?
    @current_user = current_user
  end

  def show
    @featured_dances = @user.dances.searchable_by(current_user).where(publish: :all).alphabetical
    @reclusive_dances = @user.dances.searchable_by(current_user, personal_page: true).where(publish: :link).alphabetical
    @programs = @user.programs
  end

  def update_preferences
    user = User.find(params[:user_id])
    if user.update(update_preferences_params)
      redirect_to root_path(user), notice: 'Preferences updated.'
    else
      render :update
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def update_preferences_params
    params.require(:user).permit(:id, :moderation, :news_email)
  end
end
