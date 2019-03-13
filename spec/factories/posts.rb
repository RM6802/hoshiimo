FactoryBot.define do
  factory :post do
    sequence(:name) { |n| "Post-#{n}" }
    purchased false
    published false
    user
  end
end
