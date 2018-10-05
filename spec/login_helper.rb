# from https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara :
include Warden::Test::Helpers
Warden.test_mode!

def with_login(user: nil, admin: false, blogger: false, password: nil, really_login: true, &block)
  raise "can't both pass a user and specify admin - pick one" if user && admin
  raise "can't both pass a user and specify blogger - pick one" if user && blogger
  raise "can't both pass a user and specify password - pick one" if user && password
  password ||= 'aaaaaaaa'
  user ||= FactoryGirl.create(:user, password: password, admin: admin, blogger: blogger)
  login_as(user) if really_login
  begin
    block.call user
  ensure
    logout if really_login
  end
end
