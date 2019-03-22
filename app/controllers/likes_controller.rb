class LikesController < ApplicationController
  before_action :authenticate_user!, except: [:liker]

  def like
    @post = Post.published.find_by(id: params[:id])
    if @post
      current_user.liked_posts << @post
      redirect_to request.referrer || root_url, notice: "いいねしました。"
    end
  end

  def unlike
    post = Post.published.find_by(id: params[:id])
    if post
      current_user.liked_posts.destroy(post)
      redirect_to request.referrer || root_url, notice: "いいねを取り消しました。"
    end
  end

  def liked
    @posts = current_user.liked_posts.published.order("likes.created_at DESC").page(params[:page]).per(10)
  end

  def liker
    @post = Post.published.find_by(id: params[:id])
    if @post
      @users = @post.likers.order("likes.created_at DESC").page(params[:page]).per(10)
    end
  end
end
