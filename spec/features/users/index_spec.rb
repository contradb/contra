require 'rails_helper'
require 'login_helper'
require 'support/scrutinize_layout'

describe 'Creating user from welcome page' do
  let(:user) {FactoryGirl.create(:user, news_email: true)}

  it "shows a table of users" do
    user
    visit users_path
    scrutinize_layout page
    expect(page).to have_link(user.name, href: user_path(user))
  end

  describe "newsletter mailto" do
    it "doesn't show when not admin" do
      user
      visit users_path
      expect(page).to_not have_link('write a newsletter')
    end

    it "shows when admin" do
      user
      user2 = FactoryGirl.create(:user, news_email: true)
      _private_user = FactoryGirl.create(:user, news_email: false)
      with_login(admin: true) do |admin|
        bccs = [user, user2, admin].map(&:email).join('%2C').gsub('@','%40')
        visit users_path
        # mailto:dc.morse@gmail.com?bcc=allisonjonjak%40gmail.com%2Cdcmorse%40gmail.com
        # mailto:test@test.com?bcc=spam.me.harder.1%40gmail.com%2Cspam.me.harder.2%40gmail.com%2Ctest%40test.com
        puts page.html
        expect(page).to have_link('write a newsletter...', href: "mailto:#{admin.email}?bcc=#{bccs}")
      end
    end
  end
end
