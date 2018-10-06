class BlogsController < ApplicationController
  def index
    @blogs = Blog.order(:sort_at).select {|blog| blog.readable?(current_user)}
    @show_blogger_controls = Blog.writeable?(current_user)
  end

  def show
    @blog = Blog.find(params[:id])
    authenticate_blog_readable!(@blog)
    @show_blogger_controls = @blog.writeable?(current_user)
  end

  def new
    @blog = Blog.new(sort_at: DateTime.now)
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
      deny_or_login!(deny_notice: "Oops! You're not authorized to do that.",
                     login_notice: "Oops! You're not authorized to do that. If you're a blogger you could try logging in.",
                     fallback_location: blogs_path)
    end
  end

  def blog_params
    params.require(:blog).permit(:title, :body, :publish, :sort_at)
  end
end
