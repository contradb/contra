class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  def authenticate_ownership! (user_id)
    unless signed_in? && (current_user.id == user_id)
      flash[:notice] = "Please access one of your own pages"
      redirect_to(:back)
    end
  end

  def authenticate_administrator!
    unless signed_in? && current_user.admin?
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
