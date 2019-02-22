class Post < ApplicationRecord
  belongs_to :user

  validates :name,  presence: true, length: { maximum: 200 }
  validates :posted_at,  presence: true

  #公開ポスト
  scope :published, -> { where(published: true) }
  #任意のユーザーのポストと公開ポスト
  scope :full, ->(user) { where("user_id = ?", user.id).or(published) }
  #任意のユーザーのポスト
  #scope :user_post, ->(user) { where("user_id = ?", user.id) }
  #任意のユーザーがいた場合は、そのユーザーのポスト公開ポスト、いなければ公開ポスト
  scope :readable_for, ->(user) { user ? full(user) : published }

  # scope :full, ->(member) { where("member_id = ? OR status <> ?", member.id, "draft") }
  # scope :readable_for, ->(member) { member ? full(member) : common }

  scope :purchased, -> { where(purchased: true) }
  scope :unpurchased, -> { where(purchased: false) }
end
