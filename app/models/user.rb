class User < ActiveRecord::Base

  has_many :microposts, dependent: :destroy
                                        #ユーザーがユーザー自体が破棄されたときに、そのユーザーに依存するマイクロポスト (つまり特定のユーザーのもの) も破棄されることを指定

  #ユーザー/リレーションシップのhas_manyの関連付けを実装
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  #ユーザーを削除したら、ユーザーのリレーションシップも同時に削除される必要がある。そのため、関連付けにdependent: :destroyを追加している。

  #Userモデルのfollowed_users関連付けを追加
  has_many :followed_users, through: :relationships, source: :followed

  #逆リレーションシップのためにわざわざデータベーステーブルを1つ余分に作成するようなことはしなくてOK。

  #代わりに、フォロワーとフォローしているユーザーの関係が対称的であることを利用し、単にfollowed_idを主キーとして渡すことでreverse_relationshipsをシミュレートすればいい。

  #すなわち、
  has_many :reverse_relationships, foreign_key: "followed_id", class_name: "Relationship", dependent: :destroy
  #クラス名を明示的に含める必要があることに注意。これをしていないと、Railsは実在しないReverseRelationshipクラスを探しに行ってしまう。

  has_many :followers, through: :reverse_relationships, source: :follower
  #ここではsourceキーを省略してもOK。理由は、:followers属性の場合、Railsが “followers” を単数形にして自動的に外部キーfollower_idを探してくれるから。

  has_secure_password
  before_save { self.email = email.downcase }
  before_create :create_remember_token
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def feed
    Micropost.from_users_followed_by(self)
  end

  #following?ユーティリティメソッド
  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  #follow! ユーティリティメソッド
  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  #ユーザーのリレーションシップを削除してフォロー解除
  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end