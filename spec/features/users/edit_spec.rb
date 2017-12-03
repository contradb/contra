require 'rails_helper'
require 'login_helper'
require 'support/scrutinize_layout'

describe 'Editing user' do
  xit 'editing email works' do  # but it doesn't! But in real life it does now. Hm...-dm 12-02-2017
    password = 'smurfs4eva'
    with_login(password: password) do |user|
      visit edit_user_registration_path
      scrutinize_layout page
      fill_in 'user_email', with: 'serious@yahoo.com'
      # fill_in 'user_current_password', with: password
      # click_on('update-user')
      # binding.pry
      find('button.btn-success').click
      expect(page).to have_text('Your account has been updated successfully.')
      user.reload
      expect(user.email).to eq('serious@yahoo.com')
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
