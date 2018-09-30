class BlogsController < ApplicationController
  before_action :set_blog, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_blog_readable!, except: [:index]

  def index
    @blogs = Blog.all.select {|blog| blog.readable?(current_user)}
  end

  def show
  end

  # def new
  #   @blog = Blog.new
  # end

  # def edit
  # end

  # def create
  #   @blog = Blog.new(blog_params)

  #   if @blog.save
  #     redirect_to @blog, notice: 'Blog was successfully created.'
  #   else
  #     render :new
  #   end
  # end

  # def update
  #   if @blog.update(blog_params)
  #     redirect_to @blog, notice: 'Blog was successfully updated.'
  #   else
  #     render :edit
  #   end
  # end

  # def destroy
  #   @blog.destroy
  #   redirect_to blogs_url, notice: 'Blog was successfully destroyed.'
  # end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_blog
    @blog = Blog.find(params[:id])
  end

  def authenticate_blog_readable!
    unless @blog.readable?(current_user)
      deny_or_login!(deny_notice: "Oops! That blog is unpublished.",
                     login_notice: "Oops! That blog is unpublished. If you're a blogger you could try logging in",
                     fallback_location: blogs_path)
    end
  end

  def blog_params
    params.require(:blog).permit(:title, :body, :user_id)
  end
end
