require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe "#index" do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:post1) { create(:post, user: user, published: true) }
    let!(:post2) { create(:post, user: user, published: false) }
    let!(:other_post) { create(:post, user: other_user) }
    let!(:users_post) { [post1, post2] }

    context "ログインユーザーの場合" do
      before do
        sign_in user
        get :index
      end

      it "正常にレスポンスを返すこと" do
        expect(response).to be_successful
      end

      it "200レスポンスを返すこと" do
        expect(response).to have_http_status "200"
      end

      it "indexテンプレートを表示させる" do
        expect(response).to render_template :index
      end

      it "本人の投稿一覧が閲覧可能" do
        expect(assigns(:posts)).to match_array(users_post)
      end

      it "他のユーザーの投稿は表示されない" do
        expect(assigns(:posts)).not_to include other_post
      end
    end

    context "ゲストユーザーの場合" do
      before do
        get :index
      end

      it "正常にレスポンスを返すこと" do
        expect(response).to be_successful
      end

      it "200レスポンスを返すこと" do
        expect(response).to have_http_status "200"
      end

      it "indexテンプレートを表示させる" do
        expect(response).to render_template :index
      end

      it "投稿は表示されない" do
        expect(assigns(:posts)).to eq nil
      end
    end
  end

  describe "#about" do
    before do
      get :about
    end

    it "レスポンスが成功する" do
      expect(response).to be_successful
    end

    it "200レスポンスを返す" do
      expect(response).to have_http_status 200
    end

    it "aboutテンプレートを表示させる" do
      expect(response).to render_template :about
    end
  end
end
