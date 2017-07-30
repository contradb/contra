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
    expect(page).to have_text(dance.created_at.strftime('%Y-%m-%d'))
  end

  it 'displays in descencing updated_at order by default' do
    dance
    dance2 = FactoryGirl.create(:dance, title: "The First Dance", updated_at: DateTime.now + 1.minute)
    dance3 = FactoryGirl.create(:dance, title: "The Last Dance", updated_at: DateTime.now - 1.minute)
    visit '/'
    expect(page).to have_content(/#{dance2.title}.*#{dance.title}.*#{dance3.title}/)
  end
end
