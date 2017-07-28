# coding: utf-8
require 'rails_helper'
require 'login_helper'

describe 'Welcome page', js: true do
  let (:dance) {FactoryGirl.create(:dance)}
  it 'displays dance columns' do
    dance
    visit '/'
    expect(page).to have_text(dance.title)
    expect(page).to have_text(dance.choreographer.name)
    expect(page).to have_text(dance.user.name)
  end
end
