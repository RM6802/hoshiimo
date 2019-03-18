require 'rails_helper'

RSpec.describe PurchasesController, type: :controller do
  describe "#index" do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:post1) { create(:post, user: user, published: true, purchased: true) }
    let!(:post2) { create(:post, user: user, published: false, purchased: true) }
    let!(:post3) { create(:post, user: user, published: true) }
    let!(:other_post1) { create(:post, user: other_user, published: true, purchased: true) }
    let!(:other_post2) { create(:post, user: other_user, published: false, purchased: true) }
    let!(:purchased_users_post) { [post1, post2] }
    let!(:purchased_and_published_post) { [post1, other_post1] }
    let!(:unpublished_post) { [post2, other_post2] }

    context "全ユーザーの公開購入済一覧" do
      before do
        get :index
      end

      it "正常にレスポンスを返すこと" do
        expect(response).to be_successful
      end

      it "200レスポンスを返すこと" do
        expect(response).to have_http_status 200
      end

      it "indexテンプレートを表示させる" do
        expect(response).to render_template :index
      end

      it "購入済の公開投稿のみ閲覧可能" do
        expect(assigns(:purchases)).to match_array(purchased_and_published_post)
      end

      it "非公開投稿は非表示" do
        expect(assigns(:purchases)).not_to include(unpublished_post)
      end

      it "未購入の投稿は非表示" do
        expect(assigns(:purchases)).not_to include(post3)
      end
    end

    context "個人の投稿一覧" do
      it "正常にレスポンスを返すこと" do
        get :index, params: { user_id: user.id }
        expect(response).to be_successful
      end

      it "200レスポンスを返すこと" do
        get :index, params: { user_id: user.id }
        expect(response).to have_http_status 200
      end

      it "indexテンプレートを表示させる" do
        get :index, params: { user_id: user.id }
        expect(response).to render_template :index
      end

      it "@userの割り当て" do
        get :index, params: { user_id: user.id }
        expect(assigns(:user)).to eq user
      end

      context "本人が閲覧した場合" do
        it "本人の購入済一覧が閲覧可能" do
          sign_in user
          get :index, params: { user_id: user.id }
          expect(assigns(:purchases)).to match_array(purchased_users_post)
        end
      end

      context "他のユーザーが閲覧した場合" do
        it "当該ユーザーの公開購入済一覧のみ閲覧可能" do
          sign_in other_user
          get :index, params: { user_id: user.id }
          expect(assigns(:purchases)).to match_array(post1)
        end
      end

      context "ゲストユーザーが閲覧した場合" do
        it "当該ユーザーの公開購入済一覧のみ閲覧可能" do
          get :index, params: { user_id: user.id }
          expect(assigns(:purchases)).to match_array(post1)
        end
      end
    end
  end
end
