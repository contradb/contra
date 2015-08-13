module WelcomeHelper
  WELCOME_BTN_ATTR = {class: "btn btn-default btn-md", type: "button"}.freeze
  def sign_up_button_html()
    link_to 'Sign Up', new_user_registration_path, WELCOME_BTN_ATTR
  end
  def login_button_html()
    link_to 'Login', new_user_session_path, WELCOME_BTN_ATTR
  end
  def about_button_html()
    link_to 'About', about_path, WELCOME_BTN_ATTR
  end

end
