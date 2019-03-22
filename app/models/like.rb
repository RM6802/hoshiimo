class Like < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validate do
    unless user && user.likeable_for?(post)
      errors.add(:base, :invalid)
    end
  end
end
