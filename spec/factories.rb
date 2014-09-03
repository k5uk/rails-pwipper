FactoryGirl.define do
  factory :user do

    #ユーザー名もすべて異なるものにしておくふぁためにsequencesメソッドを使う（参照：http://yoshifumisato.jeez.jp/wordpress/post/rails/1088）
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}

    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end

  #マイクロポスト作成用。以下のようにマイクロポスト用のファクトリーの定義にuserを含めるだけで、マイクロポストに関連付けられるユーザーのことがFactory Girlに伝わる。
  factory :micropost do
    content "Lorem ipsum"
    user
  end
end