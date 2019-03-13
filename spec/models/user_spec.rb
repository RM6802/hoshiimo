require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーションテスト" do
    it "名前、メールアドレス、パスワード、確認用パスワードがあれば゙有効" do
      expect(build(:user)).to be_valid
    end

    it "名前がなければ無効" do
      user = build(:user, name: nil)
      user.valid?
      expect(user.errors[:name]).to include("を入力してください")
    end

    it "重複した名前は無効" do
      user = create(:user, name: "User")
      user = build(:user, name: "User")
      user.valid?
      expect(user.errors[:name]).to include("はすでに存在します")
    end

    it "名前は50文字まで" do
      user = build(:user, name: "a" * 51)
      user.valid?
      expect(user.errors[:name]).to include("は50文字以内で入力してください")
    end

    it "メールアドレスがなければ無効" do
      user = build(:user, email: nil)
      user.valid?
      expect(user.errors[:email]).to include("を入力してください")
    end

    it "重複したメールアドレスは無効" do
      user = create(:user, email: "user@example.com")
      user = build(:user, email: "user@example.com")
      user.valid?
      expect(user.errors[:email]).to include("はすでに存在します")
    end

    it "パスワードがなければ無効" do
      user = build(:user, password: nil)
      user.valid?
      expect(user.errors[:password]).to include("を入力してください")
    end

    it "パスワードが確認用のものと一致しなければ無効" do
      user = build(:user, password_confirmation: "hogehoge")
      user.valid?
      expect(user.errors[:password_confirmation]).to include("とパスワードの入力が一致しません")
    end
  end
end
