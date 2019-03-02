class HomeController < ApplicationController
  def index
    if user_signed_in?
      @posts  = current_user.posts.unpurchased.order(created_at: :desc).page(params[:page]).per(10)
    end
  end

  def about
  end
end
