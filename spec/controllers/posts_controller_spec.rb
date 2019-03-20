require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  describe "#index" do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:post1) { create(:post, user: user, published: true) }
    let!(:post2) { create(:post, user: user, published: false) }
    let!(:other_post1) { create(:post, user: other_user, published: true) }
    let!(:other_post2) { create(:post, user: other_user, published: false) }
    let!(:users_post) { [post1, post2] }
    let!(:published_post) { [post1, other_post1] }
    let!(:unpublished_post) { [post2, other_post2] }

    context "全ユーザーの公開投稿一覧" do
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

      it "公開投稿のみ閲覧可能" do
        expect(assigns(:posts)).to match_array(published_post)
      end

      it "非公開投稿は非表示" do
        expect(assigns(:posts)).not_to include(unpublished_post)
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
        it "本人の投稿一覧が閲覧可能" do
          sign_in user
          get :index, params: { user_id: user.id }
          expect(assigns(:posts)).to match_array(users_post)
        end
      end

      context "他のユーザーが閲覧した場合" do
        it "当該ユーザーの公開投稿のみ閲覧可能" do
          sign_in other_user
          get :index, params: { user_id: user.id }
          expect(assigns(:posts)).to match_array(post1)
        end
      end

      context "ゲストユーザーが閲覧した場合" do
        it "当該ユーザーの公開投稿のみ閲覧可能" do
          get :index, params: { user_id: user.id }
          expect(assigns(:posts)).to match_array(post1)
        end
      end
    end
  end

  describe "#show" do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:post) { create(:post, user: user, published: true) }
    let!(:other_post) { create(:post, user: other_user) }

    context "公開用投稿は誰でも閲覧可能" do
      before do
        get :show, params: { id: post.id }
      end

      it "正常にレスポンスを返すこと" do
        expect(response).to be_successful
      end

      it "200レスポンスを返す" do
        expect(response).to have_http_status 200
      end

      it "showテンプレートを返す" do
        expect(response).to render_template :show
      end
    end

    context "非公開投稿は本人以外閲覧不可" do
      context "本人の場合" do
        before do
          sign_in other_user
          get :show, params: { id: other_post.id }
        end

        it "正常にレスポンスを返す" do
          expect(response).to be_successful
        end

        it "200レスポンスを返す" do
          expect(response).to have_http_status 200
        end

        it "showテンプレートを返す" do
          expect(response).to render_template :show
        end
      end

      context "本人以外の場合" do
        it "専用のテンプレートを返す" do
          sign_in user
          get :show, params: { id: other_post.id }
          expect(response).to render_template "errors/not_found_or_unpublished"
        end
      end
    end
  end

  describe "#new" do
    let!(:user) { create(:user) }

    context "ログインユーザーの場合" do
      before do
        sign_in user
        get :new
      end

      it "レスポンスが成功する" do
        expect(response).to be_successful
      end

      it "200レスポンスを返す" do
        expect(response).to have_http_status 200
      end

      it "@postの割り当て" do
        expect(assigns(:post)).to be_a_new Post
      end

      it "newテンプレートを返す" do
        expect(response).to render_template :new
      end
    end

    context "ゲストユーザーの場合" do
      before do
        get :new
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

      it "@postが割り当てられない" do
        expect(assigns(:post)).not_to be_a_new Post
      end
    end
  end

  describe "#edit" do
    let!(:user) { create(:user) }
    let!(:post) { create(:post, user: user) }
    let!(:other_user) { create(:user) }

    context "本人の場合" do
      before do
        sign_in user
        get :edit, params: { id: post.id }
      end

      it "レスポンスが成功する" do
        expect(response).to be_successful
      end

      it "200レスポンスを返す" do
        expect(response).to have_http_status 200
      end

      it "@postの割り当て" do
        expect(assigns(:post)).to eq post
      end

      it "editテンプレートを返す" do
        expect(response).to render_template :edit
      end
    end

    context "他のユーザーの場合" do
      before do
        sign_in other_user
        get :edit, params: { id: post.id }
      end

      it "レスポンスが失敗する" do
        expect(response).not_to be_successful
      end

      it "302レスポンスを返す" do
        expect(response).to have_http_status 302
      end

      it "ホーム画面にリダイレクトする" do
        expect(response).to redirect_to(root_url)
      end

      it "@postにnilが入る" do
        expect(assigns(:post)).to eq nil
      end
    end

    context "ゲストユーザーの場合" do
      before do
        get :edit, params: { id: post.id }
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

      it "@postにnilが入る" do
        expect(assigns(:post)).to eq nil
      end
    end
  end

  describe "#create" do
    let!(:user) { create(:user) }
    let(:post_attributes) { attributes_for(:post) }
    let!(:other_user) { create(:user) }

    context "本人の場合" do
      before do
        sign_in user
      end

      it "302レスポンスを返す" do
        post :create, params: { post: post_attributes }
        expect(response).to have_http_status 302
      end

      it "投稿を作成する" do
        expect { post :create, params: { post: post_attributes } }.to change(user.posts, :count).by(1)
      end

      it "投稿を作成したら、ユーザーの投稿一覧ページにリダイレクトする" do
        post :create, params: { post: post_attributes }
        expect(response).to redirect_to(user_posts_path(user))
      end
    end

    context "他のユーザーの場合" do
      before do
        sign_in other_user
        post :create, params: { post: post_attributes }
      end

      it "レスポンスが失敗する" do
        expect(response).not_to be_successful
      end

      it "302レスポンスを返す" do
        expect(response).to have_http_status 302
      end

      it "他のユーザーの投稿一覧にリダイレクトする" do
        expect(response).to redirect_to(user_posts_path(other_user))
      end
    end

    context "ゲストユーザーの場合" do
      before do
        post :create, params: { post: post_attributes }
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

  describe "#update" do
    let!(:user) { create(:user) }
    let!(:post) { create(:post, user: user) }
    let!(:post_params) { attributes_for(:post, name: "New Post Name") }
    let!(:other_user) { create(:user) }

    context "ログインユーザーの場合" do
      before do
        sign_in user
        patch :update, params: { id: post.id, post: post_params }
      end

      it "302レスポンスを返す" do
        expect(response).to have_http_status 302
      end

      it "@postの割り当て" do
        expect(assigns(:post)).to eq post
      end

      it "投稿を更新する" do
        expect(post.reload.name).to eq "New Post Name"
      end

      it "投稿を作成したら、ユーザーの投稿一覧ページにリダイレクトする" do
        expect(response).to redirect_to(user_posts_path(user))
      end
    end

    context "他のユーザーの場合" do
      before do
        sign_in other_user
        patch :update, params: { id: post.id, post: post_params }
      end

      it "レスポンスが失敗する" do
        expect(response).not_to be_successful
      end

      it "302レスポンスを返す" do
        expect(response).to have_http_status 302
      end

      it "@postにnilが入る" do
        expect(assigns(:post)).to eq nil
      end

      it "投稿の更新に失敗する" do
        expect(post.reload.name).to eq post.name
      end

      it "ホーム画面にリダイレクトする" do
        expect(response).to redirect_to(root_url)
      end
    end

    context "ゲストユーザーの場合" do
      before do
        patch :update, params: { id: post.id, post: post_params }
      end

      it "レスポンスが失敗する" do
        expect(response).not_to be_successful
      end

      it "302レスポンスを返す" do
        expect(response).to have_http_status 302
      end

      it "@postにnilが入る" do
        expect(assigns(:post)).to eq nil
      end

      it "投稿の更新に失敗する" do
        expect(post.reload.name).to eq post.name
      end

      it "ログインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "#destroy" do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:post) { create(:post, user: user) }

    context "ログインユーザーの場合" do
      before do
        sign_in user
      end

      it "302レスポンスを返す" do
        delete :destroy, params: { id: post.id }
        expect(response).to have_http_status 302
      end

      it "@postの割り当て" do
        delete :destroy, params: { id: post.id }
        expect(assigns(:post)).to eq post
      end

      it "投稿を削除する" do
        expect { delete :destroy, params: { id: post.id } }.to change(user.posts, :count).by(-1)
      end

      # request.envで元ページのurlを書き込む
      context "削除元のページがある場合" do
        it "削除に成功したら、元のページにリダイレクトする" do
          request.env['HTTP_REFERER'] = user_posts_url(user)
          delete :destroy, params: { id: post.id }
          expect(response).to redirect_to(user_posts_url(user))
        end
      end

      context "削除元のページがない場合" do
        it "削除に成功したら、ホーム画面にリダイレクトする" do
          delete :destroy, params: { id: post.id }
          expect(response).to redirect_to(root_url)
        end
      end
    end

    context "他のユーザーの場合" do
      before do
        sign_in other_user
      end

      it "レスポンスが失敗する" do
        delete :destroy, params: { id: post.id }
        expect(response).not_to be_successful
      end

      it "302レスポンスを返す" do
        delete :destroy, params: { id: post.id }
        expect(response).to have_http_status 302
      end

      it "@postにnilが入る" do
        expect(assigns(:post)).to eq nil
      end

      it "ホーム画面にリダイレクトする" do
        delete :destroy, params: { id: post.id }
        expect(response).to redirect_to(root_url)
      end
    end

    context "ゲストユーザーの場合" do
      it "レスポンスが失敗する" do
        delete :destroy, params: { id: post.id }
        expect(response).not_to be_successful
      end

      it "302レスポンスを返す" do
        delete :destroy, params: { id: post.id }
        expect(response).to have_http_status 302
      end

      it "@postにnilが入る" do
        expect(assigns(:post)).to eq nil
      end

      it "ログインページにリダイレクトする" do
        delete :destroy, params: { id: post.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "#search" do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:post1) { create(:post, name: "ABCD", user: user, published: true) }
    let!(:post2) { create(:post, name: "ABC", user: user, published: false) }
    let!(:post3) { create(:post, name: "AB", user: other_user, published: true) }
    let!(:post4) { create(:post, name: "A", user: other_user, published: false) }
    let!(:post5) { create(:post, name: "XYZ", user: other_user, published: true) }

    it "正常にレスポンスを返すこと" do
      get :search, params: { q: "A" }
      expect(response).to be_successful
    end

    it "200レスポンスを返すこと" do
      get :search, params: { q: "A" }
      expect(response).to have_http_status 200
    end

    it "searchテンプレートを表示させる" do
      get :search, params: { q: "A" }
      expect(response).to render_template :search
    end

    context "ログインユーザーの場合" do
      before do
        sign_in user
      end

      it "自身の投稿と他ユーザーの公開投稿が検索できる" do
        get :search, params: { q: "A" }
        expect(assigns(:posts)).to eq [post1, post2, post3]
      end

      it "一致するものがない時は何も返さない" do
        get :search, params: { q: "Q" }
        expect(assigns(:posts)).to be_empty
      end

      it "空欄での検索時は、全ての自身の投稿と他ユーザーの公開投稿を返す" do
        get :search, params: { q: "" }
        expect(assigns(:posts)).to eq [post1, post2, post3, post5]
      end
    end

    context "ゲストユーザーの場合" do
      it "公開投稿のみ検索できる" do
        get :search, params: { q: "A" }
        expect(assigns(:posts)).to eq [post1, post3]
      end

      it "一致するものがない時は何も返さない" do
        get :search, params: { q: "Q" }
        expect(assigns(:posts)).to be_empty
      end

      it "空欄での検索時は、全ての公開投稿を返す" do
        get :search, params: { q: "" }
        expect(assigns(:posts)).to eq [post1, post3, post5]
      end
    end
  end
end
