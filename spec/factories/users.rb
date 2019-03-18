FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User-#{n}" }
    sequence(:email) { |n| "user-#{n}@example.com" }
    password "foobar"
    password_confirmation "foobar"
    confirmed_at { Object::Date.today }
  end
end
