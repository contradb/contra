require 'rails_helper'

describe 'Blog create' do
  it "reminds users to log in" do
    password = 'abc123ABC'
    user = FactoryGirl.create(:user, blogger: true, password: password)

    visit(new_blog_path)
    expect(page).to have_content("Oops! You're not authorized to view that page. If you're a blogger you could try logging in")
    expect(page).to have_current_path(new_user_session_path)

    fill_in('user_email', with: user.email)
    fill_in('user_password', with: password)
    click_on 'Login'
    expect(page).to have_css(:h1, text: 'New Blog')
    expect(page).to have_current_path(new_blog_path)
  end

  it "saves form values" do
    attrs = FactoryGirl.attributes_for(:blog, publish: true, sort_at: DateTime.new(2018,10,1))
    with_login(blogger: true) do |user|
      visit(new_blog_path)
      fill_in('blog_title', with: attrs[:title])
      fill_in('blog_body', with: attrs[:body])
      fill_in('blog_sort_at', with: attrs[:sort_at])
      check('blog[publish]') if attrs[:publish]
      click_on('Save Blog')
      expect(page).to have_css(:h1, text: attrs[:title])
      blog = Blog.last
      expect(page).to have_current_path(blog_path(blog))
      [:title, :body, :publish, :sort_at].each do |attr|
        value = blog.public_send(attr)
        expect(value).to eq(attrs[attr]), "blog.#{attr} => #{value} but expected #{attrs[attr].inspect}"
      end
      expect(blog.user_id).to eq(user.id)
    end
  end

  it "validates required fields" do
    with_login(blogger: true) do |user|
      visit(new_blog_path)
      fill_in('blog_title', with: '')
      fill_in('blog_body', with: '')
      fill_in('blog_sort_at', with: '')
      click_on('Save Blog')
      expect(page).to have_content("Title can't be blank")
      expect(page).to have_content("Body can't be blank")
      expect(page).to have_content("Sort at can't be blank")
    end
  end
end
