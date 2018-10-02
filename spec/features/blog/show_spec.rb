require 'rails_helper'
require 'support/scrutinize_layout'


describe 'Blog show' do
  let (:blog) {FactoryGirl.create(:blog, publish: true)}
  let (:private_blog) {FactoryGirl.create(:blog, publish: false)}

  it "looks right" do
    visit(blog_path(blog))
    scrutinize_layout(page)
    expect(page).to have_css(:h1, text: blog.title)
    expect(page).to have_content("By #{blog.user.name}")
    expect(page).to_not have_css(".warn-private-blog")
  end

  it "without login, diverts to login on the theory that they're a blogger" do
    password = 'abc123ABC'
    user = FactoryGirl.create(:user, blogger: true, password: password)

    visit(blog_path(private_blog))

    expect(page).to have_content("Oops! That blog is unpublished. If you're a blogger you could try logging in")
    expect(current_path).to eq(new_user_session_path)
    fill_in('user_email', with: user.email)
    fill_in('user_password', with: password)
    click_on 'Login'
    expect(page).to have_css(:h1, text: private_blog.title)
    expect(page).to have_css(".warn-private-blog", text: "This blog is not published")
    expect(page).to have_current_path(blog_path(private_blog))
  end

  it "with non-blogger login, refuses to let them see the blog" do
    with_login do
      visit(blog_path(private_blog))
      expect(page).to have_content("Oops! That blog is unpublished.")
      expect(page).to have_current_path(blogs_path)
    end
  end

  it "renders markdown" do
    blog = FactoryGirl.create(:blog, body: '[yahoo.com](https://www.yahoo.com) **bold** *italic*', publish: true)
    visit(blog_path(blog))
    expect(page).to have_link('yahoo.com', href: 'https://www.yahoo.com')
    expect(page).to have_css(:strong, text: 'bold')
    expect(page).to have_css(:em, text: 'italic')
  end
end
