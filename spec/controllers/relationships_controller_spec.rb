require 'rails_helper'

RSpec.describe RelationshipsController, type: :controller do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  describe "#create" do
    context "ログインユーザーの場合" do
      before do
        sign_in user
      end

      it "レスポンスが成功する" do
        post :create, format: :js, params: { followed_id: other_user.id }
        expect(response).to be_successful
      end

      it "200レスポンスを返す" do
        post :create, format: :js, params: { followed_id: other_user.id }
        expect(response).to have_http_status 200
      end

      it "JS形式でレスポンスを返す" do
        post :create, format: :js, params: { followed_id: other_user.id }
        expect(response.content_type).to eq 'text/javascript'
      end

      it "@userの割り当て" do
        post :create, format: :js, params: { followed_id: other_user.id }
        expect(assigns(:user)).to eq other_user
      end

      it "フォローに成功する" do
        expect { post :create, format: :js, params: { followed_id: other_user.id } }.to change(Relationship, :count).by(1)
      end
    end

    context "ゲストユーザーの場合" do
      it "レスポンスが失敗する" do
        post :create, format: :js, params: { followed_id: other_user.id }
        expect(response).not_to be_successful
      end

      it "401レスポンスを返す" do
        post :create, format: :js, params: { followed_id: other_user.id }
        expect(response).to have_http_status 401
      end

      it "フォローに失敗する" do
        expect { post :create, format: :js, params: { followed_id: other_user.id } }.to change(Relationship, :count).by(0)
      end
    end
  end

  describe "#destroy" do
    let!(:relationship) { create(:relationship, follower_id: user.id, followed_id: other_user.id) }

    context "ログインユーザーの場合" do
      before do
        sign_in user
      end

      it "レスポンスが成功する" do
        delete :destroy, format: :js, params: { follower_id: user.id, followed_id: other_user.id, id: relationship.id }
        expect(response).to be_successful
      end

      it "200レスポンスを返す" do
        delete :destroy, format: :js, params: { follower_id: user.id, followed_id: other_user.id, id: relationship.id }
        expect(response).to have_http_status 200
      end

      it "JS形式でレスポンスを返す" do
        delete :destroy, format: :js, params: { follower_id: user.id, followed_id: other_user.id, id: relationship.id }
        expect(response.content_type).to eq 'text/javascript'
      end

      it "@userの割り当て" do
        delete :destroy, format: :js, params: { follower_id: user.id, followed_id: other_user.id, id: relationship.id }
        expect(assigns(:user)).to eq other_user
      end

      it "フォロー解除に成功する" do
        expect { delete :destroy, format: :js, params: { follower_id: user.id, followed_id: other_user.id, id: relationship.id } }.to change(Relationship, :count).by(-1)
      end
    end

    context "ゲストユーザーの場合" do
      it "レスポンスが失敗する" do
        delete :destroy, format: :js, params: { follower_id: user.id, followed_id: other_user.id, id: relationship.id }
        expect(response).not_to be_successful
      end

      it "401レスポンスを返す" do
        delete :destroy, format: :js, params: { follower_id: user.id, followed_id: other_user.id, id: relationship.id }
        expect(response).to have_http_status 401
      end

      it "フォロー解除に失敗する" do
        expect { delete :destroy, format: :js, params: { follower_id: user.id, followed_id: other_user.id, id: relationship.id } }.to change(Relationship, :count).by(0)
      end
    end
  end
end
