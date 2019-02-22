User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             bio:   "自己紹介",
             password:              "foobar",
             password_confirmation: "foobar")

99.times do |n|
  name  = "#{Faker::Name.name}-#{n+1}"
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end

users = User.order(:created_at).take(6)
50.times do |n|
 content = Faker::Lorem.sentence(5)
 if n % 6 == 0
   purchased = true
   published = true
 elsif n % 2 == 0
   purchased = true
   published = false
 elsif n % 3 == 0
   purchased = false
   published = true
 else
   purchased = false
   published = false
 end
 users.each do |user|
   user.posts.create!(name: content,
                      posted_at: 10.days.ago,
                      purchased: purchased,
                      published: published)
 end
end
