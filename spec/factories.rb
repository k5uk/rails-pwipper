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
end