class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  validates :name,  presence: true, length: { maximum: 50 }, uniqueness: true
  validates :email, uniqueness: true
  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  def likeable_for?(post)
    post && post.user != self && !likes.exists?(post_id: post.id)
  end

  def update_without_current_password(params, *options)
    params.delete(:current_password)

    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    result = update_attributes(params, *options)
    clean_up_passwords
    result
  end
end
