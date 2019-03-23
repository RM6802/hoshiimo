require 'rails_helper'

RSpec.describe LikesController, type: :controller do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:post1) { create(:post, user: user, published: true) }
  let!(:post2) { create(:post, user: user, published: false) }
  let!(:post3) { create(:post, user: user, published: true) }

  describe "#like" do
    context "ログインユーザーの場合" do
      before do
        sign_in other_user
      end

      it "レスポンスが成功する" do
        patch :like, format: :js, params: { id: post1.id }
        expect(response).to be_successful
      end

      it "200レスポンスを返す" do
        patch :like, format: :js, params: { id: post1.id }
        expect(response).to have_http_status 200
      end

      it "JS形式でレスポンスを返す" do
        patch :like, format: :js, params: { id: post1.id }
        expect(response.content_type).to eq 'text/javascript'
      end

      it "@postの割り当て" do
        patch :like, format: :js, params: { id: post1.id }
        expect(assigns(:post)).to eq post1
      end

      it "いいねに成功する" do
        expect { patch :like, format: :js, params: { id: post1.id } }.to change(Like, :count).by(1)
      end

      it "非公開投稿はいいねができない" do
        expect { patch :like, format: :js, params: { id: post2.id } }.to change(Like, :count).by(0)
      end
    end

    context "ゲストユーザーの場合" do
      it "レスポンスが失敗する" do
        patch :like, format: :js, params: { id: post1.id }
        expect(response).not_to be_successful
      end

      it "401レスポンスを返す" do
        patch :like, format: :js, params: { id: post1.id }
        expect(response).to have_http_status 401
      end

      it "いいねに失敗する" do
        expect { patch :like, format: :js, params: { id: post1.id } }.to change(Like, :count).by(0)
      end
    end
  end

  describe "#unlike" do
    let!(:like1) { create(:like, user_id: other_user.id, post_id: post1.id) }
    let!(:like2) { create(:like, user_id: other_user.id, post_id: post2.id) }

    context "ログインユーザーの場合" do
      before do
        sign_in other_user
      end

      it "レスポンスが成功する" do
        patch :unlike, format: :js, params: { id: post1.id }
        expect(response).to be_successful
      end

      it "200レスポンスを返す" do
        patch :unlike, format: :js, params: { id: post1.id }
        expect(response).to have_http_status 200
      end

      it "JS形式でレスポンスを返す" do
        patch :unlike, format: :js, params: { id: post1.id }
        expect(response.content_type).to eq 'text/javascript'
      end

      it "いいねの取り消しに成功する" do
        expect { patch :unlike, format: :js, params: { id: post1.id } }.to change(Like, :count).by(-1)
      end

      it "非公開になった投稿はいいねの取り消しができない" do
        expect { patch :unlike, format: :js, params: { id: post2.id } }.to change(Like, :count).by(0)
      end
    end

    context "ゲストユーザーの場合" do
      before do
        patch :unlike, format: :js, params: { id: post1.id }
      end

      it "レスポンスが失敗する" do
        expect(response).not_to be_successful
      end

      it "401レスポンスを返す" do
        expect(response).to have_http_status 401
      end

      it "いいねの取り消しに失敗する" do
        expect { patch :unlike, params: { id: post1.id } }.to change(Like, :count).by(0)
      end
    end
  end

  describe "#liked" do
    let!(:like1) { create(:like, user_id: other_user.id, post_id: post1.id) }
    let!(:like2) { create(:like, user_id: other_user.id, post_id: post2.id) }
    let!(:like3) { create(:like, user_id: other_user.id, post_id: post3.id) }

    context "ログインユーザーの場合" do
      before do
        sign_in other_user
        get :liked
      end

      it "正常にレスポンスを返すこと" do
        expect(response).to be_successful
      end

      it "200レスポンスを返すこと" do
        expect(response).to have_http_status 200
      end

      it "likedテンプレートを表示させる" do
        expect(response).to render_template :liked
      end

      it "公開投稿のいいねのみ確認可能" do
        expect(assigns(:posts)).to match_array [post1, post3]
      end

      it "非公開投稿のいいねは非表示" do
        expect(assigns(:posts)).not_to include(post2)
      end
    end

    context "ゲストユーザーの場合" do
      before do
        get :liked
      end

      it "レスポンスが失敗する" do
        expect(response).not_to be_successful
      end

      it "302レスポンスを返す" do
        expect(response).to have_http_status 302
      end

      it "ログインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "#liker" do
    let!(:user2) { create(:user) }
    let!(:like1) { create(:like, user_id: other_user.id, post_id: post1.id) }
    let!(:like2) { create(:like, user_id: other_user.id, post_id: post2.id) }
    let!(:like3) { create(:like, user_id: user2.id, post_id: post1.id) }

    it "正常にレスポンスを返すこと" do
      get :liker, params: { id: post1.id }
      expect(response).to be_successful
    end

    it "200レスポンスを返すこと" do
      get :liker, params: { id: post1.id }
      expect(response).to have_http_status 200
    end

    it "likerテンプレートを表示させる" do
      get :liker, params: { id: post1.id }
      expect(response).to render_template :liker
    end

    it "公開投稿のみ確認可能" do
      get :liker, params: { id: post1.id }
      expect(assigns(:post)).to eq post1
    end

    it "非公開投稿には割り当てられない" do
      get :liker, params: { id: post2.id }
      expect(assigns(:post)).to eq nil
    end

    it "公開投稿にいいねしているユーザーが確認できる" do
      get :liker, params: { id: post1.id }
      expect(assigns(:users)).to match_array [other_user, user2]
    end
  end
end
