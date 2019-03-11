class UnpurchasesController < ApplicationController
  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @unpurchases = @user.posts.readable_for(current_user).unpurchased.order(created_at: :desc).page(params[:page]).per(10)
    else
      @unpurchases = Post.published.unpurchased.order(created_at: :desc).page(params[:page]).per(10)
    end
  end
end
