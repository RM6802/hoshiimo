require 'rails_helper'

RSpec.describe Relationship, type: :model do
  describe "バリデーションテスト" do
    it "フォロワー、被フォローユーザーがあれば有効" do
      user = create(:user)
      other_user = create(:user)
      expect(build(:relationship, follower_id: user.id, followed_id: other_user.id)).to be_valid
    end

    it "フォロワーがいなければ無効" do
      other_user = create(:user)
      relationship = build(:relationship, followed_id: other_user.id)
      relationship.valid?
      expect(relationship.errors[:follower_id]).to include("を入力してください")
    end

    it "被フォローユーザーがいなければ無効" do
      user = create(:user)
      relationship = build(:relationship, follower_id: user.id)
      relationship.valid?
      expect(relationship.errors[:followed_id]).to include("を入力してください")
    end
  end
end
