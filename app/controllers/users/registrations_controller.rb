

class Users::RegistrationsController < Devise::RegistrationsController
  after_action :create_first_user_as_admin, only: :create

  private

  def create_first_user_as_admin
    User.first.update(admin: true) if 1==User.all.count
  end
end
