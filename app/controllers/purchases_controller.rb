class PurchasesController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      @purchases = @user.posts.readable_for(current_user).purchased.order(posted_at: :desc).page(params[:page]).per(10)
    else
      @purchases = Post.published.purchased.order(posted_at: :desc).page(params[:page]).per(10)
    end
  end
end
