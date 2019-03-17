require 'rails_helper'

RSpec.feature "Users", type: :feature do
  include_examples :sign_in
  let!(:other_user) { create(:user, bio: "こんにちは") }

  background do
    sign_in current_user
  end

  scenario "ユーザー情報の編集画面に移動し、プロフィールを変更する" do
    visit user_path(current_user)
    expect(page).to have_current_path(user_path(current_user))
    expect(page).to have_title "#{current_user.name} | Hoshiimo"
    expect(page).to have_link "#{current_user.name} (投稿一覧へ)"
    expect(page).to have_selector 'p', text: current_user.bio
    expect(page).to have_link "ユーザー情報編集"
    expect(page).to have_link "新規投稿を作成"
    click_on "ユーザー情報編集"
    expect(page).to have_current_path(edit_user_registration_path)
    fill_in "ユーザー名", with: "test-user"
    fill_in "自己紹介", with: "こんにちは"
    click_on "更新"
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "アカウント情報を変更しました。"
    visit user_path(current_user)
    expect(page).to have_link "test-user (投稿一覧へ)"
    expect(page).to have_selector 'p', text: "こんにちは"
  end

  scenario "ユーザー情報の編集画面に移動し、アカウントを削除する" do
    visit user_path(current_user)
    click_on "ユーザー情報編集"
    expect(page).to have_button "アカウントを削除"
    expect { click_button "アカウントを削除" }.to change { User.count }.by(-1)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "アカウントを削除しました。またのご利用をお待ちしております。"
  end

  scenario "ユーザー一覧ページから、他ユーザーの詳細ページに移行する" do
    visit users_path
    expect(page).to have_title "ユーザー一覧 | Hoshiimo"
    expect(page).to have_selector '.list-group', text: current_user.name
    expect(page).to have_selector '.list-group', text: current_user.bio
    click_on other_user.name
    expect(page).to have_link "#{other_user.name} (公開投稿一覧へ)"
  end


  scenario "他のユーザーでログインし、ユーザー一覧ページにアクセスする" do
    visit user_path(current_user)
    find('.log-out').click
    expect(page).to have_current_path(root_path)
    sign_in other_user
    visit users_path
    expect(page).to have_current_path(users_path)
    expect(page).to have_selector '.list-group', text: current_user.name
    expect(page).to have_selector '.list-group', text: current_user.bio
    expect(page).to have_selector '.list-group', text: other_user.name
    expect(page).to have_selector '.list-group', text: other_user.bio
    find('.log-out').click
    expect(page).to have_current_path(root_path)
  end
end
