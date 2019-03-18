require 'rails_helper'

RSpec.feature "SignUps", type: :feature do
  feature "ユーザーはサインアップに成功する" do
    background do
      ActionMailer::Base.deliveries.clear
    end

    scenario "ユーザー登録を行い、アカウント認証後にログインする" do
      visit root_path
      expect(page).to have_http_status :ok

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
        expect { click_on "新規登録" }.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
      expect(page).to have_current_path(root_path)
      expect(page).to have_content "本人確認用のメールを送信しました。メール内のリンクからアカウントを有効化させてください。"

      mail = ActionMailer::Base.deliveries.last

      aggregate_failures do
        expect(mail.to).to eq ["test@example.com"]
        expect(mail.from).to eq ["info@hoshiimo-app.herokuapp.com"]
        expect(mail.subject).to eq "メールアドレス確認メール"
        expect(mail.body).to match "hoshiimo-appにようこそ!"
        expect(mail.body).to match "次のリンクでメールアドレスの確認が完了します:"
        expect(mail.body).to match "アカウントを確認"
      end

      user = User.last
      token = user.confirmation_token
      visit user_confirmation_path(confirmation_token: token)
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content "アカウントを登録しました。"

      # ログインに失敗する場合
      # 一致しないパスワードを入力する
      fill_in "Eメール", with: "test@example.com"
      fill_in "パスワード", with: "hogehoge"
      within '.actions' do
        click_on "ログイン"
      end
      expect(page).to have_content "Eメールまたはパスワードが違います。"

      # ログインに成功する場合
      fill_in "Eメール", with: "test@example.com"
      fill_in "パスワード", with: "foobar"
      within '.actions' do
        click_on "ログイン"
      end
      expect(page).to have_content "ログインしました。"

      # ログアウト後に再度ログインする
      find('.log-out').click
      expect(page).to have_content "ログアウトしました。"
      within '.signin' do
        click_on "ログイン"
      end
      fill_in "Eメール", with: "test@example.com"
      fill_in "パスワード", with: "foobar"
      within '.actions' do
        click_on "ログイン"
      end
      expect(page).to have_content "ログインしました。"
    end
  end
end
