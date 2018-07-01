require 'rails_helper'

describe 'login and logout', js: true do
  it 'work' do
    password = 'aaaaaaaa'
    user = FactoryGirl.create(:user, password: password)
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: password
    click_button 'Login'
    expect(page).to have_content('Signed in successfully.')
    click_link(user.name)
    click_link('logout')
    expect(page).to have_content('Signed out successfully.')
  end
end
