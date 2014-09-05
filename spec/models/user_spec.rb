require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name)}
  it { should respond_to(:email)}
  it { should respond_to(:password_digest)}
  it { should respond_to(:password)}
  it { should respond_to(:password_confirmation)}
  it { should respond_to(:remember_token)}
  it { should respond_to(:authenticate)}

  #admin属性に対するテスト
  it { should respond_to(:admin) }

  #microposts属性に対するテスト
  it { should respond_to(:microposts) }

  #feed属性に対するテスト
  it { should respond_to(:feed) }

  #user.relationships属性のテスト
  it { should respond_to(:relationships) }

  #user.followed_users属性のテスト
  it { should respond_to(:followed_users) }

  #逆リレーションシップのテスト
  it { should respond_to(:reverse_relationships) }

  #フォロワー属性に対するテスト
  it { should respond_to(:followers) }

  #admin属性に対するテスト
  it { should_not be_admin }

  it { should be_valid }


  #admin属性に対するテスト
  describe "with admin attribute set to 'true'" do
    before do
      @user.save!

      #toggle!メソッドを使用して、admin属性の状態をfalseからtrueに反転
      @user.toggle!(:admin)
    end

    it { should be_admin }
    #これはユーザーに対してadmin?メソッド (論理値を返す) が使用できる必要があることを (RSpecの論理値慣習に基いて) 示している。
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid}
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid}
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid}
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when password is not present" do
    before do
        @user = User.new(name: "Example User", email: "user@example.com", password: " ", password_confirmation: " ")
      end
      it { should_not be_valid }
    end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank}
  end

  describe "micropost associations" do

    before { @user.save }

    #「let!」を使って強制的にマイクロポストを作成
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right microposts in the right order" do

      #新しいポストが最初に来ることをテスト

      #デフォルトでは id順に並ぶため[older_micropost, newer_micropost]の順序になりテストは失敗するはず。

      #またこのテストは、user.micropostsが有効なマイクロポストの配列を返すことをチェックすることにより、基本的なhas_many関連付け自体の正しさも確認している。

      #to_aメソッドは、 @user.micropostsをデフォルトの状態から正しい配列に変換。変換された配列は、手作りの配列と比較可能になる。
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    #ユーザーを破棄するとマイクロポストも破棄されることをテスト
    it "should destroy associated microposts" do

      #micropostsという変数にmicropostsの中身をコピー
      microposts = @user.microposts.to_a

      #ユーザーを削除
      @user.destroy

      #一種のセフティチェックの役割も果たしており、うっかりto_aメソッドを付け忘れたときのエラーをすべてキャッチ
      expect(microposts).not_to be_empty

      # マイクロポストがデータベースからなくなったことを確認
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    #ステータスフィードのテスト
    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end

      #feedメソッドが自分のマイクロポストは含むが他ユーザーのマイクロポストは含まないことをテスト。このテストでは、与えられた要素が配列に含まれているかどうかをチェックするinclude?メソッドを使用
      its(:feed) { should include(newer_micropost) }
      its(:feed) { should include(older_micropost) }
      its(:feed) { should_not include(unfollowed_post) }
    end
  end

  # “フォロー用の” ユーティリティメソッドをいくつかテスト
  describe "following" do

    #other_userを作成
    let(:other_user) { FactoryGirl.create(:user) }

    before do
      #ユーザーを保存
      @user.save
      #ユーザーをフォロー
      @user.follow!(other_user)
      #follow!メソッドは、relationships関連付けを経由してcreate!を呼び出すことで、「フォローする」のリレーションシップを作成する。

    end

    #other_userをフォローしているべきである
    it { should be_following(other_user) }

    #フォローする相手のユーザーがデータベース上に存在するかどうかをチェック
    its(:followed_users) { should include(other_user) }

    describe "followed user" do

      subject { other_user }
      #subjectメソッドを使用して@userからother_userに対象を切り替えていることで、フォロワーのリレーションシップのテストを自然に実行できる。

      #@userがother_userをフォローした時点で、other_userのフォロワーに@userが含まれることになる。これはother_userのフォローデータベースにother_userが含まれていることをテストしている。
      its(:followers) { should include(@user) }
    end

    #ユーザーのフォロー解除をテスト
    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }

      #other_userがフォローされているべきではない
      it { should_not be_following(other_user) }

      #ふぉろーしてしたユーザーがデータベース上に存在していないことをチェック
      its(:followed_users) { should_not include(other_user) }

    end
  end
end