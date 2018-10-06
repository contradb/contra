require 'rails_helper'
require 'support/scrutinize_layout'


describe 'Blog index' do
  let (:blog) {FactoryGirl.create(:blog, publish: true)}
  let (:unpublished) {FactoryGirl.create(:blog, publish: false)}

  it "lists published blogs" do
    blog
    unpublished
    visit(blogs_path)
    expect(page).to have_link(blog.title, href: blog_path(blog))
    expect(page).to_not have_link(unpublished.title)
    expect(page).to_not have_text('publish')
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
