#それらしい名前とメールアドレスを持つ99のユーザーを作成し、従来のユーザーと置き換える。

namespace :db do
  desc "FIll database with sample data"
  task populate: :environment do

#リファクタリングと、フォローしている、またはフォローされている関係を表すリレーションシップのサンプル作成フローを追加。

=begin
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
=end

    #関数の実行
    make_users
    make_microposts
    make_relationships

  end
end

#各関数の作成

def make_users
  admin = User.create!(name: "Admin User", email: "admin@railstutorial.jp", password: "foobar", password_confirmation: "foobar", admin: true)
  #create!は基本的にcreateメソッドと同じものですが、ユーザーが無効な場合にfalseを返すのではなく例外を発生させる

  99.times do |n|
    name  = Faker::Name.name
    email = "example-#{n+1}@railstutorial.jp"
    password  = "password"
    User.create!(name: name, email: email, password: password, password_confirmation: password)
  end
end

def make_microposts

  #6名を上限にユーザーをusersに代入
  users = User.limit(6)

  #各ユーザーに対して50個のマイクロポストを作成
  50.times do
    content = Faker::Lorem.sentence(5)
    users.each { |user| user.microposts.create!(content: content) }
  end
end

#リレーションシップの作成
def make_relationships
  users = User.all
  user = users.first
  followed_users = users[2..50]
  followers          = users[3..40]
  followed_users.each { |followed| user.follow!(followed) }
  followers.each          { |follower| follower.follow!(user) }
end