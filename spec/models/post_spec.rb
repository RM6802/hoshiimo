require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "バリデーションのテスト" do
    it "投稿名、購入状態、公開状態゙があれば有効" do
      expect(build(:post)).to be_valid
    end

    it "投稿名がなければ無効" do
      post = build(:post, name: nil)
      post.valid?
      expect(post.errors[:name]).to include("を入力してください")
    end

    it "投稿名は50文字まで" do
      post = build(:post, name: "a" * 51)
      post.valid?
      expect(post.errors[:name]).to include("は50文字以内で入力してください")
    end

    it "購入状態が無いものは無効" do
      post = build(:post, purchased: nil)
      post.valid?
      expect(post.errors[:purchased]).to include("は一覧にありません")
    end

    it "公開状態が無いものは無効" do
      post = build(:post, published: nil)
      post.valid?
      expect(post.errors[:published]).to include("は一覧にありません")
    end

    it "商品説明は500文字まで" do
      post = build(:post, description: "a" * 501)
      post.valid?
      expect(post.errors[:description]).to include("は500文字以内で入力してください")
    end

    it "値段が整数以外の時は無効" do
      post = build(:post, price: 100.1)
      post.valid?
      expect(post.errors[:price]).to include("は整数で入力してください")
    end

    it "値段が0未満の時は無効" do
      post = build(:post, price: -100)
      post.valid?
      expect(post.errors[:price]).to include("は0以上の値にしてください")
    end

    it "ユーザーが削除されると紐づいた投稿も削除されること" do
      user = create(:user, name: "Tom")
      post = create(:post, user: user)
      expect { user.destroy }.to change(Post, :count).by(-1)
    end

    it "一人のユーザーが複数の投稿を所持できる" do
      user = create(:user, name: "Tom")
      post1 = create(:post, user: user)
      post2 = create(:post, user: user)
      expect(post2).to be_valid
    end
  end

  describe "スコープのテスト" do
    let!(:user1) { create(:user, name: "first_user") }
    let!(:user2) { create(:user, name: "second_user") }
    let!(:user3) { create(:user, name: "third_user") }
    let(:post1) { create(:post, published: false, purchased: false, user: user1) }
    let(:post2) { create(:post, published: false, purchased: false, user: user2) }
    let(:post3) { create(:post, published: true, purchased: true, user: user1) }
    let(:post4) { create(:post, published: true, purchased: true, user: user2) }

    describe "公開状態の投稿を検索する" do
      context "一致するデータが見つかるとき" do
        it "一致する投稿を返すこと" do
          expect(Post.published).to eq [post3, post4]
        end
      end

      context "一致するデータが見つからないとき" do
        it "空のコレクションを返すこと" do
          expect(Post.published).to be_empty
        end
      end
    end

    describe "任意のユーザーの投稿または公開投稿を検索する" do
      context "一致するデータが見つかるとき" do
        it "一致する投稿を返すこと" do
          expect(Post.full(user1)).to eq [post1, post3, post4]
        end
      end

      context "一致するデータが見つからないとき" do
        it "空のコレクションを返すこと" do
          expect(Post.full(user3)).to be_empty
        end
      end
    end

    describe "readable_forスコープの検証" do
      context "投稿の中に任意のユーザーによる投稿がある場合" do
        it "ユーザーの投稿または公開投稿を検索する" do
          expect(Post.readable_for(user1)).to eq [post1, post3, post4]
        end
      end

      context "投稿の中に任意のユーザーによる投稿がない場合" do
        it "公開投稿を検索する" do
          expect(Post.readable_for(user3)).to eq [post3, post4]
        end
      end
    end

    describe "購入状態を検索条件にする" do
      describe "purchasedスコープの検証" do
        context "一致するデータが見つかるとき" do
          it "一致する投稿を返すこと" do
            expect(Post.purchased).to eq [post3, post4]
          end
        end

        context "一致するデータが見つからないとき" do
          it "空のコレクションを返すこと" do
            expect(Post.purchased).to be_empty
          end
        end
      end

      describe "unpurchasedスコープの検証" do
        context "一致するデータが見つかるとき" do
          it "一致する投稿を返すこと" do
            expect(Post.unpurchased).to eq [post1, post2]
          end
        end

        context "一致するデータが見つからないとき" do
          it "空のコレクションを返すこと" do
            expect(Post.unpurchased).to be_empty
          end
        end
      end
    end
  end
end
