require 'rails_helper'

describe "user profile" do
  it "works" do
    user = FactoryGirl.create(:user, news_email: true)
    dance = FactoryGirl.create(:dance, user: user)
    program = FactoryGirl.create(:program, user: user)
    visit user_path(user)
    expect(page).to have_css(:h1, text: user.name)
    expect(page).to have_link(dance.title, href: dance_path(dance))
    expect(page).to have_link(program.title), href: program_path(program)
    expect(page).to_not have_text('Administrator')
    expect(page).to_not have_text('Blogger')
  end

  it "displays Administrator" do
    visit user_path(FactoryGirl.create(:user, admin: true))
    expect(page).to have_css(:h2, text: "Administrator")
  end

  it "displays Blogger" do
    visit user_path(FactoryGirl.create(:user, blogger: true))
    expect(page).to have_css(:h2, text: "Blogger")
  end
end
