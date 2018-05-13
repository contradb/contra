require 'rails_helper'
require 'login_helper'
require 'support/scrutinize_layout'
include Warden::Test::Helpers

describe 'Editing user' do
  it 'editing Identity works' do
    current_password = 'smurfs4eva'
    new_password = 'smurfs are so last year'
    with_login(password: current_password) do |user|
      visit edit_user_registration_path
      scrutinize_layout page
      fill_in 'user_name', with: 'Yahoo Serious'
      fill_in 'user_email', with: 'serious@yahoo.com'
      fill_in 'user_current_password', with: current_password
      fill_in 'user_password', with: new_password
      fill_in 'user_password_confirmation', with: new_password
      click_button 'Update Identity'
      expect(page).to have_text('Your account has been updated successfully.')
      user.reload
      expect(user.name).to eq('Yahoo Serious')
      expect(user.email).to eq('serious@yahoo.com')
      logout(:user)
      visit new_user_session_path
      fill_in 'user_email', with: 'serious@yahoo.com'
      fill_in 'user_password', with: new_password
      click_button 'Login'
      expect(page).to have_content('Signed in successfully')
    end
  end

  it 'editing contact info works' do
    with_login do |user|
      visit edit_user_registration_path
      choose "user_moderation_private"
      choose "user_news_email_false"
      click_button('Update Notifications')
      user.reload
      expect(page).to have_text('Preferences updated.')
      expect(current_url).to eq(root_url)
      expect(user.moderation).to eq('private')
      expect(user.news_email?).to eq(false)
    end
  end

  it 'deleting account works' do
    with_login do |user|
      visit edit_user_registration_path
      find('.btn-danger').click
      expect(page).to have_text('Your account has been successfully cancelled.')
      expect(User.find_by(id: user.id)).to be(nil)
    end
  end
end
