class Post < ApplicationRecord
  belongs_to :user
  validates :name, presence: true, length: { maximum: 200 }
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }
  validates :posted_at, presence: true
  validates :purchased, :published, inclusion: { in: [true, false] }

  #公開ポスト
  scope :published, -> { where(published: true) }
  #任意のユーザーのポストと公開ポスト
  scope :full, ->(user) { where("user_id = ?", user.id).or(published) }
  #任意のユーザーのポスト
  #scope :user_post, ->(user) { where("user_id = ?", user.id) }
  #任意のユーザーがいた場合は、そのユーザーのポストと公開ポスト、いなければ公開ポスト
  scope :readable_for, ->(user) { user ? full(user) : published }

  scope :purchased, -> { where(purchased: true) }
  scope :unpurchased, -> { where(purchased: false) }
end
