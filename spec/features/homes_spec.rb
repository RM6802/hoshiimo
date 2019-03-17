require 'rails_helper'

RSpec.feature "Homes", type: :feature do

  given!(:user) { create(:user) }

  context "ゲストユーザーの場合" do
    scenario "文章やリンクが表示される" do
      visit root_path
      expect(page).to have_current_path(root_path)
      expect(page).to have_title "Hoshiimo"
      expect(page).to have_selector "h1", text: "欲しいものを記録する"
      expect(page).to have_selector "p", text: "管理から共有まで自由な使い方を"
      within('.form-wrap') do
        expect(page).to have_link "新規登録"
        expect(page).to have_link "ログイン"
      end
      within('.navbar') do
        expect(page).to have_link "Home"
        expect(page).to have_link "About"
        expect(page).to have_link "ユーザー一覧"
        expect(page).to have_link "公開投稿一覧"
        expect(page).to have_link "新規登録"
        expect(page).to have_link "ログイン"
      end
    end
  end

  context "ログインユーザーの場合" do
    include_examples :sign_in
    scenario "投稿一覧が表示される" do
      sign_in current_user

      visit root_path
      expect(page).to have_current_path(root_path)
      expect(page).to have_title "Hoshiimo"
      expect(page).to have_selector "h3", text: "#{current_user.name}さんの投稿一覧"
      expect(page).to have_selector ".green", text: "緑:未購入"
      expect(page).to have_selector ".red", text: "赤:購入済"
      expect(page).to have_link "新規投稿を作成"
      expect(page).to have_link "#{current_user.name}さんの未購入一覧へ"
      expect(page).to have_link "#{current_user.name}さんの購入済一覧へ"
      within('.posts') do
        expect(page).to have_link "#{current_user.name}"
        expect(page).to have_link "#{current_user_post.name}"
        expect(page).to have_selector ".published", text: "公開設定："
        expect(page).to have_selector ".timestamp", text: "投稿時間："
        expect(page).to have_link "削除"
      end
    end
  end

  scenario "Aboutリンクからアプリの説明ページに遷移する" do
    visit root_path
    click_on "About"
    expect(page).to have_current_path(about_path)
    expect(page).to have_title "About | Hoshiimo"
    expect(page).to have_selector "h2", text: "干し芋appとは"
  end

  scenario "新規登録画面に移動し、ユーザー情報を送信するとホーム画面に遷移する" do
    visit root_path
    within '.signup' do
      click_on "新規登録"
    end
    expect(page).to have_current_path(new_user_registration_path)
    expect(page).to have_title "新規登録 | Hoshiimo"
    expect(page).to have_selector "h4", text: "新規登録"
    fill_in "ユーザー名", with: "TestUser"
    fill_in "Eメール", with: "test@example.com"
    fill_in "パスワード", with: "foobar"
    fill_in "パスワード（確認用）", with: "foobar"
    within '.actions' do
      click_on "新規登録"
    end
    expect(page).to have_current_path(root_path)
  end

  scenario "ログイン画面に移動し、ログインを実行する" do
    visit root_path
    within '.signin' do
      click_on "ログイン"
    end
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_title "ログイン | Hoshiimo"
    expect(page).to have_selector "h4", text: "ログイン"
    expect(page).to have_link "新規登録はこちら"
    expect(page).to have_link "パスワードをお忘れですか?"
    expect(page).to have_link "アカウント確認のメールを受け取っていませんか?"
    fill_in "Eメール", with: user.email
    fill_in "パスワード", with: user.password
    within '.actions' do
      click_on "ログイン"
    end
    expect(page).to have_current_path(root_path)
  end
end
