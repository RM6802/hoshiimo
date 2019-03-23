class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search]
  before_action :correct_user, only: [:edit, :update, :destroy]

  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @posts = @user.posts.readable_for(current_user).order(created_at: :desc).page(params[:page]).per(10)
    else
      @posts = Post.published.order(created_at: :desc).page(params[:page]).per(10)
    end
  end

  def show
    @post = Post.readable_for(current_user).find_by(id: params[:id])
    if @post
      render 'show'
    else
      render 'errors/not_found_or_unpublished'
    end
  end

  def new
    @post = Post.new
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      redirect_to user_posts_path(current_user), notice: "投稿を作成しました。"
    else
      render "new"
    end
  end

  def update
    if @post.update_attributes(post_params)
      redirect_to user_posts_path(current_user), notice: "投稿内容を更新しました。"
    else
      render 'edit'
    end
  end

  def destroy
    @post.destroy
    redirect_to request.referrer || root_url, notice: "投稿を削除しました。"
  end

  def search
    @posts = Post.readable_for(current_user).search(params[:q]).order(created_at: "DESC").page(params[:page]).per(10)
  end

  def timeline
    @feed_items = current_user.feed.full(current_user).order(created_at: "DESC").page(params[:page]).per(10)
  end

  private

  def post_params
    params.require(:post).permit(:name, :description, :price,
                                 :purchased, :purchased_at, :published)
  end

  def correct_user
    @post = current_user.posts.find_by(id: params[:id])
    redirect_to(root_url) if @post.nil?
  end
end
