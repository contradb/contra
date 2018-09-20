# from https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara :
include Warden::Test::Helpers
Warden.test_mode!

def with_login(user: nil, admin: false, password: nil, &block)
  raise "can't both pass a user and specify admin - pick one" if user && admin
  raise "can't both pass a user and specify password - pick one" if user && password
  password ||= 'aaaaaaaa'
  user ||= FactoryGirl.create(:user, password: password, admin: admin)
  login_as(user)
  begin
    block.call user
  ensure
    logout
  end
end
