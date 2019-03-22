require 'rails_helper'

RSpec.describe Like, type: :model do
  describe "バリデーションテスト" do
    it "ユーザー、当該ユーザー以外の投稿、いいねされていない投稿があれば゙有効" do
      user = create(:user)
      other_user = create(:user)
      post = create(:post, user_id: other_user.id)
      expect(build(:like, user_id: user.id, post_id: post.id)).to be_valid
    end

    it "ユーザーがなければ無効" do
      other_user = create(:user)
      post = create(:post, user_id: other_user.id)
      like = build(:like, post_id: post.id)
      like.valid?
      expect(like.errors[:base]).to include("は不正な値です")
    end

    it "自身の投稿へのいいねは無効" do
      user = create(:user)
      post = create(:post, user_id: user.id)
      like = build(:like, user_id: user.id, post_id: post.id)
      like.valid?
      expect(like.errors[:base]).to include("は不正な値です")
    end

    it "投稿がなければ無効" do
      user = create(:user)
      like = build(:like, user_id: user.id)
      like.valid?
      expect(like.errors[:base]).to include("は不正な値です")
    end

    it "自身がすでにいいねしている投稿は無効" do
      user = create(:user)
      other_user = create(:user)
      post = create(:post, user_id: other_user.id)
      like = create(:like, user_id: user.id, post_id: post.id)
      like2 = build(:like, user_id: user.id, post_id: post.id)
      like2.valid?
      expect(like2.errors[:base]).to include("は不正な値です")
    end
  end
end
