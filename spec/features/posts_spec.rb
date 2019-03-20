require 'rails_helper'

RSpec.feature "Posts", type: :feature do
  let!(:other_user) { create(:user) }
  let!(:other_post1) { create(:post, user: other_user, published: true, purchased: true) }
  let!(:other_post2) { create(:post, user: other_user, published: false) }
  let!(:other_post3) { create(:post, user: other_user, published: true, purchased: false) }

  include_examples :sign_in

  background do
    sign_in current_user
  end

  scenario "投稿作成画面に移動し、投稿する", js: true do
    visit new_post_path
    expect(page).to have_current_path(new_post_path)

    # 投稿が失敗する場合
    fill_in "商品名 (必須)", with: ""
    fill_in "商品説明", with: "hogehoge"
    fill_in "値段", with: -1000
    choose "unpurchased"
    choose "published"
    expect { click_on "投稿" }.to change(Post, :count).by(0)
    expect(page).to have_content "商品名を入力してください"
    expect(page).to have_content "値段は0以上の値にしてください"

    # 投稿が成功する場合
    fill_in "商品名 (必須)", with: "テスト商品"
    fill_in "商品説明", with: "hogehoge"
    fill_in "値段", with: 1000
    choose "purchased"
    select 2019, from: 'post_purchased_at_1i'
    select 1, from: 'post_purchased_at_2i'
    select 1, from: 'post_purchased_at_3i'
    choose "published"
    expect { click_on "投稿" }.to change(Post, :count).by(1)
    expect(page).to have_current_path(user_posts_path(current_user.id))
    expect(page).to have_content "投稿を作成しました。"
  end

  context "全ユーザーの公開投稿一覧" do
    scenario "公開投稿一覧ページから、投稿詳細ページに移行する" do
      visit posts_path
      expect(page).to have_current_path(posts_path)

      click_on "#{other_post1.name}"
      expect(page).to have_current_path(post_path(other_post1.id))
      expect(page).to have_link "#{other_post1.user.name}"
      expect(page).to have_selector '.card-title', text: other_post1.name
      expect(page).to have_selector '.card-text', text: "購入済"
      expect(page).to have_selector '.card-text', text: "#{other_post1.created_at.strftime("%Y/%m/%d")}"
      expect(page).to have_selector '.card-text', text: "公開"
    end

    scenario "公開投稿一覧、未購入一覧、購入済一覧の順にページを移動する" do
      visit posts_path
      expect(page).to have_current_path(posts_path)
      expect(page).to have_selector "h3", text: "公開投稿一覧"
      expect(page).to have_selector ".green", text: "緑:未購入"
      expect(page).to have_selector ".red", text: "赤:購入済"
      expect(page).to have_link "新規投稿を作成"
      expect(page).to have_link "未購入一覧へ"
      expect(page).to have_link "購入済一覧へ"
      within('.posts') do
        expect(page).to have_content "#{other_user.name} (公開投稿一覧へ)"
        expect(page).to have_link "#{other_post1.name}"
        expect(page).to have_selector ".timestamp", text: "投稿時間："
        expect(page).to have_no_link "#{other_post2.name}"
        expect(page).to have_link "#{other_post3.name}"
      end

      click_on "未購入一覧へ"
      expect(page).to have_current_path(unpurchases_path)
      expect(page).to have_selector "h3", text: "未購入一覧(公開用)"
      expect(page).to have_link "新規投稿を作成"
      expect(page).to have_link "投稿一覧へ"
      expect(page).to have_link "購入済一覧へ"
      within('.posts') do
        expect(page).to have_content "#{other_user.name} (公開投稿一覧へ)"
        expect(page).to have_link "#{other_post3.name}"
        expect(page).to have_selector ".timestamp", text: "投稿時間："
        expect(page).to have_no_link "#{other_post1.name}"
        expect(page).to have_no_link "#{other_post2.name}"
      end

      click_on "購入済一覧へ"
      expect(page).to have_current_path(purchases_path)
      expect(page).to have_selector "h3", text: "購入済一覧(公開用)"
      expect(page).to have_link "新規投稿を作成"
      expect(page).to have_link "投稿一覧へ"
      expect(page).to have_link "未購入一覧へ"
      within('.posts') do
        expect(page).to have_content "#{other_user.name} (公開投稿一覧へ)"
        expect(page).to have_link "#{other_post1.name}"
        expect(page).to have_selector ".timestamp", text: "投稿時間："
        expect(page).to have_no_link "#{other_post2.name}"
        expect(page).to have_no_link "#{other_post3.name}"
      end
    end
  end

  context "個人の投稿一覧" do
    scenario "自身の投稿一覧ページから詳細をクリックし、投稿詳細ページに移行する" do
      visit user_posts_path(current_user.id)
      expect(page).to have_current_path(user_posts_path(current_user.id))

      click_on "#{current_user_post.name}"
      expect(page).to have_current_path(post_path(current_user_post.id))
      expect(page).to have_link "#{current_user_post.user.name}"
      expect(page).to have_link "編集"
      expect(page).to have_selector '.card-title', text: current_user_post.name
      expect(page).to have_selector '.card-text', text: "未購入"
      expect(page).to have_selector '.card-text', text: "#{other_post1.created_at.strftime("%Y/%m/%d")}"
      expect(page).to have_selector '.card-text', text: "非公開"
    end

    scenario "投稿一覧、未購入一覧、購入済一覧の順にページを移動する" do
      visit user_path(current_user)
      find('.log-out').click
      sign_in other_user
      visit user_posts_path(other_user.id)
      expect(page).to have_current_path(user_posts_path(other_user.id))
      expect(page).to have_selector "h3", text: "#{other_user.name}さんの投稿一覧"
      expect(page).to have_selector ".green", text: "緑:未購入"
      expect(page).to have_selector ".red", text: "赤:購入済"
      expect(page).to have_link "新規投稿を作成"
      expect(page).to have_link "#{other_user.name}さんの未購入一覧へ"
      expect(page).to have_link "#{other_user.name}さんの購入済一覧へ"
      within('.posts') do
        expect(page).to have_content "#{other_user.name}"
        expect(page).to have_link "#{other_post1.name}"
        expect(page).to have_link "#{other_post2.name}"
        expect(page).to have_link "#{other_post3.name}"
        expect(page).to have_selector ".published", text: "公開設定：非公開"
        expect(page).to have_selector ".timestamp", text: "投稿時間："
        expect(page).to have_link "削除"
      end

      click_on "#{other_user.name}さんの未購入一覧へ"
      expect(page).to have_current_path(user_unpurchases_path(other_user.id))
      expect(page).to have_selector "h3", text: "#{other_user.name}さんの未購入一覧"
      expect(page).to have_link "新規投稿を作成"
      expect(page).to have_link "#{other_user.name}さんの投稿一覧へ"
      expect(page).to have_link "#{other_user.name}さんの購入済一覧へ"
      within('.posts') do
        expect(page).to have_content "#{other_user.name}"
        expect(page).to have_link "#{other_post2.name}"
        expect(page).to have_link "#{other_post3.name}"
        expect(page).to have_selector ".timestamp", text: "投稿時間："
        expect(page).to have_no_link "#{other_post1.name}"
      end

      click_on "#{other_user.name}さんの購入済一覧へ"
      expect(page).to have_current_path(user_purchases_path(other_user.id))
      expect(page).to have_selector "h3", text: "#{other_user.name}さんの購入済一覧"
      expect(page).to have_link "新規投稿を作成"
      expect(page).to have_link "#{other_user.name}さんの投稿一覧へ"
      expect(page).to have_link "#{other_user.name}さんの未購入一覧へ"
      within('.posts') do
        expect(page).to have_content "#{other_user.name}"
        expect(page).to have_link "#{other_post1.name}"
        expect(page).to have_selector ".timestamp", text: "投稿時間："
        expect(page).to have_no_link "#{other_post2.name}"
        expect(page).to have_no_link "#{other_post3.name}"
      end
    end
  end

  scenario "投稿一覧ページから、投稿の削除を行う" do
    visit user_path(current_user)
    find('.log-out').click
    sign_in other_user
    visit posts_path
    expect { all('.list-group-item')[0].click_on "削除" }.to change(Post, :count).by(-1)
    expect(page).to have_current_path(posts_path)
    expect(page).to have_content "投稿を削除しました。"
    within('.posts') do
      expect(page).to have_no_link "#{other_post1.name}"
      expect(page).to have_link "#{other_post3.name}"
    end
  end

  scenario "ホーム画面から投稿を検索する" do
    visit root_path
    expect(page).to have_current_path(root_path)

    # 空欄で検索する場合
    fill_in "投稿を検索", with: ""
    click_on "検索"
    expect(page).to have_content "' 'の検索結果"
    within('.posts') do
      expect(page).to have_link "#{current_user_post.name}"
      expect(page).to have_link "#{other_post1.name}"
      expect(page).to have_link "#{other_post3.name}"
      expect(page).to have_no_link "#{other_post2.name}"
    end

    # 一致する投稿がない場合
    fill_in "投稿を検索", with: "a" * 100
    click_on "検索"
    expect(page).to have_content "' #{"a" * 100} 'の検索結果"
    expect(page).to have_content "投稿がありません"

    # 投稿が検索できた場合
    fill_in "投稿を検索", with: "#{current_user_post.name}"
    click_on "検索"
    expect(page).to have_content "' #{current_user_post.name} 'の検索結果"
    within('.posts') do
      expect(page).to have_link "#{current_user_post.name}"
    end
  end
end
