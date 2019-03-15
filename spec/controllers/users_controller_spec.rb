require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe "#index" do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:all_user) { [user, other_user] }

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

    it "全てのユーザーを取得する" do
      expect(assigns(:users)).to match_array(all_user)
    end
  end

  describe "#show" do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }

    before do
      get :show, params: { id: user.id }
    end

    it "正常にレスポンスを返すこと" do
      expect(response).to be_successful
    end

    it "200レスポンスを返すこと" do
      expect(response).to have_http_status 200
    end

    it "showテンプレートを表示させる" do
      expect(response).to render_template :show
    end

    it "当該ユーザーを取得する" do
      expect(assigns(:user)).to eq user
    end
  end
end
