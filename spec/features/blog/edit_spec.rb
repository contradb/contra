require 'rails_helper'

describe 'Blog edit' do
  let (:blog) {FactoryGirl.create(:blog, publish: true)}

  it "reminds users to log in" do
    password = 'abc123ABC'
    user = FactoryGirl.create(:user, blogger: true, password: password)

    visit(edit_blog_path(blog))
    expect(page).to have_content("Oops! You're not authorized to do that. If you're a blogger you could try logging in")
    expect(page).to have_current_path(new_user_session_path)

    fill_in('user_email', with: user.email)
    fill_in('user_password', with: password)
    click_on 'Login'
    expect(page).to have_css(:h1, text: 'Editing Blog')
    expect(page).to have_current_path(edit_blog_path(blog))
  end

  it "saves form values" do
    attrs = FactoryGirl.attributes_for(:blog,
                                       publish: true,
                                       title: 'New Title',
                                       body: 'New Body',
                                       sort_at: DateTime.new(2018,10,20))
    with_login(blogger: true) do |user|
      visit(edit_blog_path(blog))
      fill_in('blog_title', with: attrs[:title])
      fill_in('blog_body', with: attrs[:body])
      fill_in('blog_sort_at', with: attrs[:sort_at])
      check('blog[publish]') if attrs[:publish]
      click_on('Save Blog')
      expect(page).to have_css(:h1, text: attrs[:title])
      blog.reload
      expect(page).to have_current_path(blog_path(blog))
      [:title, :body, :publish, :sort_at].each do |attr|
        value = blog.public_send(attr)
        expect(value).to eq(attrs[attr]), "blog.#{attr} => #{value} but expected #{attrs[attr].inspect}"
      end
      expect(blog.user_id).to_not eq(user.id) # retain original author
    end
  end
end
