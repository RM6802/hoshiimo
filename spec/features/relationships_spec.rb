require 'rails_helper'

RSpec.feature "Relationships", type: :feature, js: true do
  let!(:other_user) { create(:user) }
  let!(:other_post1) { create(:post, user: other_user, published: true, purchased: true) }
  let!(:other_post2) { create(:post, user: other_user, published: false) }

  include_examples :sign_in

  background do
    sign_in current_user
  end

  scenario "ログインしたユーザーが他のユーザーをフォローする" do
    visit user_path(other_user)
    expect(page).to have_current_path(user_path(other_user.id))
    expect(page).to have_button "フォローする"
    before_count = Relationship.count
    click_on "フォローする"
    expect(page).to have_button "フォロー解除"
    expect(Relationship.count).to eq before_count + 1
    click_on "フォロー解除"
    expect(page).to have_selector '#following', text: other_user.following.count
    expect(Relationship.count).to eq before_count
  end

  scenario "フォロー後にフォローユーザー・フォロワーユーザー一覧ページを確認する" do
    visit user_path(other_user)
    expect(page).to have_current_path(user_path(other_user.id))
    expect(page).to have_button "フォローする"
    expect(page).to have_selector '#following', text: other_user.following.count
    expect(page).to have_selector '#followers', text: other_user.followers.count
    click_on "フォローする"
    click_on "#{other_user.following.count}"
    expect(page).to have_current_path(following_user_path(other_user.id))
    within '.col-md-8' do
      expect(page).to have_content "フォロー"
      expect(page).to have_no_content "フォロワー"
    end
    within '.col-md-4' do
      expect(page).to have_link "プロフィール詳細へ"
    end
    click_on "#{other_user.followers.count}"
    expect(page).to have_current_path(followers_user_path(other_user.id))
    within '.col-md-8' do
      expect(page).to have_content "フォロワー"
      expect(page).to have_link "#{current_user.name}"
      expect(page).to have_no_content "フォロー"
    end
    within '.col-md-4' do
      expect(page).to have_link "プロフィール詳細へ"
    end
  end

  scenario "フォロー後にタイムラインを確認する" do
    visit user_path(other_user)
    expect(page).to have_current_path(user_path(other_user.id))
    expect(page).to have_button "フォローする"
    click_on "フォローする"
    visit timeline_posts_path
    expect(page).to have_current_path(timeline_posts_path)
    expect(page).to have_content "#{current_user.name}さんのタイムライン"
    within('.posts') do
      expect(page).to have_link "#{other_user.name} (公開投稿一覧へ)"
      expect(page).to have_link "#{current_user_post.name}"
      expect(page).to have_link "#{other_post1.name}"
      expect(page).to have_no_link "#{other_post2.name}"
    end
  end
end
