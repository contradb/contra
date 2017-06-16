
# ONLY TO BE USED IN FEATURE TESTS, because I have no idea what I am doing-dm 07-04-2016

def with_login (admin: false, &block)
    # hackily sign in - there's got to be a better way
    visit '/users/sign_up'
    fill_in 'user_email', with: 'test@test.com'
    fill_in 'user_name', with: 'Testy T. Testerson'
    fill_in 'user_password',              with: 'aaaaaaaa'
    fill_in 'user_password_confirmation', with: 'aaaaaaaa'
    #click_on ' Sign Up':
    find('button[type="submit"]').click
    user = User.last
    user.update(admin: true) if admin
    block.call user
end
