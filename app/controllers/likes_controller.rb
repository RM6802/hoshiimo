class LikesController < ApplicationController
  before_action :authenticate_user!, except: [:liker]

  def like
    @post = Post.find(params[:id])
    if @post.published == true
      current_user.liked_posts << @post
      respond_to do |format|
        format.html { request.referrer || root_url }
        format.js
      end
    end
  end

  def unlike
    @post = Post.find(params[:id])
    if @post.published == true
      current_user.liked_posts.destroy(@post)
      respond_to do |format|
        format.html { request.referrer || root_url }
        format.js
      end
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
