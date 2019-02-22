class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @posts = @user.posts.readable_for(current_user).order(posted_at: :desc).page(params[:page]).per(10)
    else
      @posts = Post.published.order(posted_at: :desc).page(params[:page]).per(10)
    end
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end
end