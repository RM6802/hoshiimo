class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @posts = @user.posts.readable_for(current_user).unpurchased.order(posted_at: :desc).page(params[:page]).per(10)
    else
      @posts = Post.published.unpurchased.order(posted_at: :desc).page(params[:page]).per(10)
    end

  end


  def show
    @post = Post.readable_for(current_user).find(params[:id])
  end

  def new
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  def create
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update_attributes(post_params)
      redirect_to @post, notice: "投稿内容を更新しました。"
    else
      render 'edit'
    end
  end

  # def update
  #   @user = User.find(params[:id])
  #   if @user.update_attributes(user_params)
  #     flash[:success] = "Profile updated"
  #     redirect_to @user
  #   else
  #     render 'edit'
  #   end
  # end
  #
  # def update
  #   @post = current_user.entries.find(params[:id])
  #   @entry.assign_attributes(entry_params)
  #   if @entry.save
  #     redirect_to @entry, notice: "記事を更新しました。"
  #   else
  #     render "edit"
  #   end
  # end

  def destroy
  end

  private

    def post_params
      params.require(:post).permit(:name, :description, :price,
                                   :purchased, :purchased_at, :published)
    end

    def correct_user
      post = Post.find(params[:id])
      user = post.user
      redirect_to(root_url) unless user == current_user
    end
end
