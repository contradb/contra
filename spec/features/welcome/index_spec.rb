# coding: utf-8
require 'rails_helper'
require 'login_helper'

describe 'Welcome page', js: true do
  let (:dance) {FactoryGirl.create(:dance)}

  context 'datatable' do
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

    it 'shows only dances visible to current user' do
      with_login do |user|
        dance2 = FactoryGirl.create(:dance, title: "this dance should be visible", publish: false, user: user)
        dance3 = FactoryGirl.create(:dance, title: "this dance should be invisible", publish: false)
        visit '/'
        expect(page).to have_content(dance2.title)
        expect(page).to_not have_content(dance3.title)
      end
    end
  end

  context 'link cloud' do
    it 'has links to sluggified figures' do
      visit '/'
      expect(page).to have_link('swing', href: figure_path('swing'))
      expect(page).to have_link('do si do', href: figure_path('do-si-do'))
      expect(page).to have_link("Rory O'Moore", href: figure_path('rory-omoore'))
    end
  end
end
