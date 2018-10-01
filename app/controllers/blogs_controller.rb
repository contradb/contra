class BlogsController < ApplicationController
  def index
    @blogs = Blog.all.select {|blog| blog.readable?(current_user)}
  end

  def show
    @blog = Blog.find(params[:id])
    authenticate_blog_readable!(@blog)
  end

  def new
    @blog = Blog.new
    authenticate_blog_writable!(@blog)
  end

  def edit
    @blog = Blog.find(params[:id])
    authenticate_blog_writable!(@blog)
  end

  def create
    @blog = Blog.new(blog_params.merge(user: current_user))
    authenticate_blog_writable!(@blog)
    if @blog.save
      redirect_to(@blog, notice: 'Blog was successfully created.')
    else
      render(:new)
    end
  end

  def update
    @blog = Blog.find(params[:id])
    authenticate_blog_writable!(@blog)
    if @blog.update(blog_params)
      redirect_to @blog, notice: 'Blog was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @blog = Blog.find(params[:id])
    authenticate_blog_writable!(@blog)
    @blog.destroy
    redirect_to blogs_url, notice: 'Blog was successfully destroyed.'
  end

  private

  def authenticate_blog_readable!(blog)
    unless blog.readable?(current_user)
      deny_or_login!(deny_notice: "Oops! That blog is unpublished.",
                     login_notice: "Oops! That blog is unpublished. If you're a blogger you could try logging in.",
                     fallback_location: blogs_path)
    end
  end

  def authenticate_blog_writable!(blog)
    unless blog.writeable?(current_user)
      deny_or_login!(deny_notice: "Oops! You're not authorized to view that page.",
                     login_notice: "Oops! You're not authorized to view that page. If you're a blogger you could try logging in.",
                     fallback_location: blogs_path)
    end
  end

  def blog_params
    params.require(:blog).permit(:title, :body, :publish)
  end
end
