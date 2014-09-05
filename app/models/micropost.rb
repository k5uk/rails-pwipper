class Micropost < ActiveRecord::Base
  belongs_to :user

  #ファイル「user_spec.rb」の「it "should have the right microposts in the right order" do」のテストをパスするために、Railsのdefault_scopeにorderパラメータを渡して使用。
  default_scope -> { order('created_at DESC') }
  #DESCは SQLでいうところの “descending”であり、新しいものから古い順への降順ということ。

  validates :content, presence: true, length: { maximum: 140 }
                                                              #コンテンツの長さは上限140文字
  validates :user_id, presence: true

  #与えられたユーザーがフォふぉーしているユーザーたちのマイクロポストを返す。
  def self.from_users_followed_by(user)

    #followed_user_idsにuser.followed_user_idsを代入

    #followed_user_ids = user.followed_user_ids

    #上記のコードを以下の内容に書き換え
    followed_user_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"

    #where("user_id IN (?) OR user_id = ?", followed_user_ids,user )

    #上のコードを以下のように書き換え
    #where("user_id IN (:followed_user_ids) OR user_id = :user_id", followed_user_ids: followed_user_ids,user_id: user )
    #前者の疑問符を使用した文法も便利ですが、同じ変数を複数の場所に挿入したい場合は、後者の置き換え後の文法を使用するのがより便利

    #上のコードをさらにブラッシュアップ
    where("user_id IN (#{ followed_user_ids }) OR user_id = :user_id", user_id: user.id )
  end
end
