class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  def authenticate_ownership!(user_id)
    unless signed_in? && (current_user.id == user_id)
      flash[:notice] = "Please access one of your own pages"
      redirect_back(fallback_location: '/')
    end
  end

  def authenticate_administrator!
    unless signed_in? && current_user.admin?
      flash[:error] = "Only an admin can do this"
      redirect_back(fallback_location: '/')
    end
  end

  def deny_or_login!(deny_notice: "You don't have access to that", login_notice: "You don't have access to that - maybe you would if you logged in?")
    if current_user
      flash[:notice] = deny_notice
      redirect_back(fallback_location: root_path)
    else
      flash[:notice] = login_notice
      session[:after_login] = request.env['PATH_INFO']
      redirect_to(new_user_session_path)
    end
  end

  protected
  def after_sign_in_path_for(resource)
    session.delete(:after_login) || super
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  private
  def dialect
    current_user&.dialect || JSLibFigure.default_dialect
  end
end
