class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  # def index
  #   if params[:user_id]
  #     @user = User.find(params[:user_id])
  #     @posts = @user.posts.readable_for(current_user).order(posted_at: :desc).page(params[:page]).per(10)
  #   else
  #     @posts = Post.published.order(posted_at: :desc).page(params[:page]).per(10)
  #   end
  # end

  def index
    if !request.fullpath.include?("purchased")
      if params[:user_id]
        @user = User.find(params[:user_id])
        @posts = @user.posts.readable_for(current_user).order(posted_at: :desc).page(params[:page]).per(10)
      else
        @posts = Post.published.order(posted_at: :desc).page(params[:page]).per(10)
      end
    else
      if params[:user_id]
        @user = User.find(params[:user_id])
        @posts = @user.posts.readable_for(current_user).order(posted_at: :desc).page(params[:page]).per(10)
        render 'purchased/index'
      else
        @posts = Post.published.order(posted_at: :desc).page(params[:page]).per(10)
        render 'purchased/index'
      end
    end
  end


  def show
    @posts = Post.readable_for(current_user).find(params[:id])
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
