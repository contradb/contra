require 'rails_helper'
require 'login_helper'
require 'support/scrutinize_layout'

describe 'page layout - tested against root page', js: true do
  it 'with login' do
    with_login do |user|
      visit '/'
      scrutinize_layout(page)
      click_link(user.name)

      # expect(page).to have_link('dialect', href: dialect_path)

       expect(page).to have_link('account', href: edit_user_registration_path)
       expect(page).to have_link('dialect', href: dialect_path)
       expect(page).to have_link('contributions', href: user_path(user))
       expect(page).to have_link('logout', href: destroy_user_session_path)
      expect(page).to_not have_link('sign up')
      expect(page).to_not have_link('login')
    end
  end

  it 'without login' do
    visit '/'
    scrutinize_layout(page)
    expect(page).to have_link('sign up', href: new_user_registration_path)
    expect(page).to have_link('login', href: new_user_session_path)
    expect(page).to_not have_link('dialect')
    expect(page).to_not have_link('account')
    expect(page).to_not have_link('contributions')
    expect(page).to_not have_link('logout')
  end
end
