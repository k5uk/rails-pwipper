class User < ActiveRecord::Base

  has_many :microposts, dependent: :destroy
                                        #ユーザーがユーザー自体が破棄されたときに、そのユーザーに依存するマイクロポスト (つまり特定のユーザーのもの) も破棄されることを指定

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
    #user_idが現在のユーザーidと等しいマイクロポスト見つけるためのメソッド。現在は不完全。
    Micropost.where("user_id = ?", id)
    #上の疑問符があることで、SQLクエリにインクルードされる前にidが適切にエスケープされることを保証してくれるため、SQLインジェクションと呼ばれる深刻なセキュリティホールを避けることができる。
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end