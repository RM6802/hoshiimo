class DevisePreview < ActionMailer::Preview
  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(User.last, Devise.friendly_token)
  end

  def confirmation_instructions
    Devise::Mailer.confirmation_instructions(User.new(name: "テスト", email: "devise@railstutorial.org"), Devise.friendly_token)
  end
end
