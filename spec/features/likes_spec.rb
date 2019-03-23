require 'rails_helper'

RSpec.feature "Likes", type: :feature, js: true do
  let!(:other_user) { create(:user) }
  let!(:other_post) { create(:post, user: other_user, published: true) }

  include_examples :sign_in

  background do
    sign_in current_user
  end

  scenario "投稿一覧ページにアクセスし、いいねとその取り消しを行う" do
    visit posts_path
    expect(page).to have_current_path(posts_path)
    before_count = Like.count
    click_on "★"
    expect(page).to have_selector '.like', text: "★"
    expect(page).to have_selector '.like', text: "1"
    expect(Like.count).to eq before_count + 1
    click_on "★"
    expect(page).to have_selector '.like', text: "★"
    expect(page).to have_selector '.like', text: "0"
    expect(Like.count).to eq before_count
  end

  scenario "いいねをした投稿から、いいねをしたユーザー一覧に移動する" do
    visit posts_path
    expect(page).to have_current_path(posts_path)
    click_on "★"
    click_on "1"
    expect(page).to have_current_path(liker_post_path(other_post.id))
    expect(page).to have_content "' #{other_post.name} 'にいいねしたユーザー"
    expect(page).to have_link "#{current_user.name}"
  end

  scenario "自身のいいね一覧に移動する" do
    visit posts_path
    expect(page).to have_current_path(posts_path)
    click_on "★"
    visit liked_posts_path
    expect(page).to have_current_path(liked_posts_path)
    expect(page).to have_content "#{current_user.name}さんのいいね一覧"
    within('.posts') do
      expect(page).to have_link "#{other_user.name} (公開投稿一覧へ)"
      expect(page).to have_link "#{other_post.name}"
      expect(page).to have_content "公開設定：公開"
      expect(page).to have_selector '.like', text: "★"
      expect(page).to have_selector '.like', text: "1"
    end
  end
end
