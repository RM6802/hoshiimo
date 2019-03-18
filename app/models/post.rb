class Post < ApplicationRecord
  belongs_to :user
  validates :name, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 500 }
  validates :user_id, presence: true
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }
  validates :purchased, :published, inclusion: { in: [true, false] }
  validate :purchased_error
  validate :purchased_at_check

  # 公開ポスト
  scope :published, -> { where(published: true) }
  # 任意のユーザーのポストと公開ポスト
  scope :full, ->(user) { where("user_id = ?", user.id).or(published) }

  # 投稿の中に任意のユーザーによる投稿がある場合はそのユーザーのポストと公開ポスト、ない場合は公開ポスト
  scope :readable_for, ->(user) { user ? full(user) : published }

  scope :purchased, -> { where(purchased: true) }
  scope :unpurchased, -> { where(purchased: false) }

  private

  # 購入日が存在するならば、購入状態は購入済にする
  def purchased_error
    if purchased_at.present? && purchased == false
      errors.add(:purchased_at, "が入力されています。購入済を選択してください。")
    end
  end

  # 購入日が現在よりも後にならないようにする
  def purchased_at_check
    return if date_valid? || purchased_at.blank?
    errors.add(:purchased_at, "は本日以前にしてください") unless purchased_at <= Date.today
  end

  # 存在しない日付をチェックする
  def date_valid?
    date = purchased_at_before_type_cast
    return if date.blank? || date[1].blank? || date[2].blank? || date[3].blank?
    y = date[1]
    m = date[2]
    d = date[3]
    unless Date.valid_date?(y, m, d)
      errors.add(:purchased_at, "の値が不正です")
    end
  end
end
