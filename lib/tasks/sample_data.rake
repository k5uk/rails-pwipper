#それらしい名前とメールアドレスを持つ99のユーザーを作成し、従来のユーザーと置き換える。

namespace :db do
  desc "FIll database with sample data"
  task populate: :environment do

    admin = User.create!(name: "Admin User",
      email: "admin@railstutorial.jp",
      password: "foobar",
      password_confirmation: "foobar",
      admin: true)

    User.create!(name: "Example User",
      #create!は基本的にcreateメソッドと同じものですが、ユーザーが無効な場合にfalseを返すのではなく例外を発生させる
      email: "example@railstutorial.jp",
      password: "foobar",
      password_confirmation: "foobar")

      99.times do |n|
        name  = Faker::Name.name
        email = "example-#{n+1}@railstutorial.jp"
        password  = "password"
        User.create!(name: name,
        email: email,
        password: password,
        password_confirmation: password)
    end

    #6名を上限にユーザーをusersに代入
    users = User.limit(6)

    #各ユーザーに対して50個のマイクロポストを作成
    50.times do
      content = Faker::Lorem.sentence(5)
      users.each { |user| user.microposts.create!(content: content) }
    end

  end
end