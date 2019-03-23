class Like < ApplicationRecord
  belongs_to :post
  belongs_to :user
  validates :post_id, presence: true
  validates :user_id, presence: true

  validate do
    unless user && user.likeable_for?(post)
      errors.add(:base, :invalid)
    end
  end
end
