require 'rails_helper'

# http://localhost:3000/ has sign_up, goes to 
# http://localhost:3000/users/sign_up

class SlashTest < ActionDispatch::IntegrationTest
  test "That / is served" do
    get "/"
    assert_response :success
  end
end
