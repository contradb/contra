require 'rails_helper'
require 'support/scrutinize_layout'


describe 'Blog index' do
  let (:blog) {FactoryGirl.create(:blog, publish: true, sort_at: DateTime.new(2017,5,15))}
  let (:unpublished) {FactoryGirl.create(:blog, publish: false)}

  it "lists published blogs" do
    blog
    unpublished
    visit(blogs_path)
    expect(page).to have_link(blog.title, href: blog_path(blog))
    expect(page).to have_text(blog.sort_at.strftime('%d/%m/%Y'))
    expect(page).to_not have_link(unpublished.title)
    expect(page).to_not have_text('publish')
  end

  it "lists blogs in increasing :sort_at order" do
    [2019, 2017, 2018].map {|year| FactoryGirl.create(:blog, publish: true, sort_at: DateTime.new(year))}
    visit(blogs_path)
    expect(page).to_not have_text(/2019.*2017.*2018/)
    expect(page).to have_text(/2017.*2018.*2019/)
  end

  it "user.blogger? sees all blogs" do
    expect_to_see_unpublished_blog(FactoryGirl.create(:user, blogger: true))
  end

  it "user.admin? sees all blogs" do
    expect_to_see_unpublished_blog(FactoryGirl.create(:user, admin: true))
  end

  def expect_to_see_unpublished_blog(user)
    unpublished
    with_login(user: user) do
      visit(blogs_path)
      expect(page).to have_link(unpublished.title, href: blog_path(unpublished))
      expect(page).to have_words("#{unpublished.title} not published")
    end
  end

  it "layout" do
    visit(blogs_path)
    scrutinize_layout(page)
  end
end
