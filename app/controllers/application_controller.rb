class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?



  def authenticate_ownership!
    if signed_in? && (current_user.id == @dance.user_id)
      # continue to current_user url
    else
        flash[:error] = "Please access one of your own pages"
        redirect_to(:back)
    end
  end

  def authenticate_administrator!
    if signed_in? && (current_user.id == 1)
      # continue to current_user url
    else
        flash[:error] = "Only an admin can do this"
        redirect_to(:back)
    end
  end


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up)        << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end
end
