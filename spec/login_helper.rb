# from https://github.com/plataformatec/devise/wiki/How-To:-Test-with-Capybara :
include Warden::Test::Helpers
Warden.test_mode!

def with_login(user: nil, admin: nil, password: nil, &block)
  raise "can't both pass a user and specify admin - pick one" if user && admin
  raise "can't both pass a user and specify password - pick one" if user && password
  user ||= FactoryGirl.create(:user, email: 'test@test.com', name: 'Testerson', password: password || 'aaaaaaaa', admin: admin || false)
  login_as(user)
  begin
    block.call user
  ensure
    logout
  end
end
