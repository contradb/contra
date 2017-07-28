# coding: utf-8
require 'rails_helper'
require 'login_helper'

describe 'Welcome page', js: true do
  let (:dance) {FactoryGirl.create(:dance)}
  it 'displays dance columns' do
    dance
    visit '/'
    expect(page).to have_link(dance.title, href: dance_path(dance))
    expect(page).to have_link(dance.choreographer.name, href: choreographer_path(dance.choreographer))
    expect(page).to have_link(dance.user.name, href: user_path(dance.user))
  end
end
