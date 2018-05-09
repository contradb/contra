class Users::RegistrationsController < Devise::RegistrationsController
  after_action :create_first_user_as_admin, only: :create

  private
  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :moderation)
  end

  def create_first_user_as_admin
    User.first.update(admin: true) if 1==User.all.count
  end
end
