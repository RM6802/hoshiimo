shared_examples :sign_in do
  include Devise::Test::IntegrationHelpers

  let!(:current_user) { create :user, bio: "はじめまして" }
  let!(:current_user_post) { create(:post, user: current_user) }

  before do
    sign_in current_user
  end
end
