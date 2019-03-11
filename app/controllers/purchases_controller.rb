class PurchasesController < ApplicationController
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @purchases = @user.posts.readable_for(current_user).purchased.order(created_at: :desc).page(params[:page]).per(10)
    else
      @purchases = Post.published.purchased.order(created_at: :desc).page(params[:page]).per(10)
    end
  end
end
