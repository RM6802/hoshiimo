class HomeController < ApplicationController
  def index
    if user_signed_in?
      @posts  = current_user.posts.order(created_at: :desc).page(params[:page]).per(10)
    end
  end

  def about
  end

  def bad_request
    raise ActionController::ParameterMissing, ""
  end

  def forbidden
    raise Forbidden, ""
  end

  def internal_server_error
    raise
  end
end
