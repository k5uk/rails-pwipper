require 'spec_helper'

describe "User pages" do

  subject { page }

  #ユーザーのインデックスページのテスト
  describe "index" do

    #擬似ユーザーを作成
    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

    #ページネーションが正しく動いているかのテスト
    describe "paginatiton" do

      #サンプルユーザーの一括作成
      before(:all) { 30.times { FactoryGirl.create(:user)}}

      #サンプルユーザーの一括削除
      after(:all) { User.delete_all }

      #ページネーションのdiv表示テスト
      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do

      #一般ユーザーにはこの削除リンクを表示しないことをテスト
      it { should_not have_link('delete') }

      describe "as an admin user" do

        #adminユーザーの作成
        let(:admin) { FactoryGirl.create(:admin) }

        before do
          sign_in admin
          visit users_path
        end

        #adminユーザーに削除リンクが表示されていることをテスト
        it { should have_link('delete', href: user_path(User.first)) }

        it "should be able to delete another user" do
          expect do

            #削除リンクを持っている最初のユーザーをのeleteボタンをクリック
            click_link('delete', match: :first)

          #Userカウントが-1だけ変わる
          end.to change(User, :count).by(-1)
        end

        #管理者ユーザーの横にはdeleteボタンが表示されないことをテスト
        it { should_not have_link('delete', href: user_path(admin)) }

      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }

    #Follow/Unfollowボタンをテスト
    describe "follow/unfollow buttons" do

      #other_userを作成
      let(:other_user) { FactoryGirl.create(:user) }

      #userとしてサインイン
      before { sign_in user }

      describe "following a user" do

        #other_userのプロフィールページに遷移
        before { visit user_path(other_user) }

        it "should increment the  followed user count" do
          expect do
            click_button "Follow"

            #followingカウントを1追加
          end .to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect do
            click_button "Follow"
          end.to change(other_user.followers, :count).by(1)
        end

        #フォローしたらボタンが変わることをテスト
        describe "toggling the button" do
          before { click_button "Follow" }
          it { should have_xpath("//input[@value='Unfollow']") }
        end
      end

      describe "unfollowing a user" do
        before do
          #userがother_userをフォローする
          user.follow!(other_user)
          #other_userのプロフィール画面に遷移
          visit user_path(other_user)
        end

        it "should decrement the followed user count" do
          expect do
            click_button "Unfollow"

          #userのフォロー中のユーザーを1減らす
          end.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect do
            click_button "Unfollow"

          #other_userのフォロワーを1減らす
          end.to change(other_user.followers, :count).by(-1)
        end

        #フォローしたらボタンが変わることをテスト
        describe "toggling the button" do
          before { click_button "Unfollow" }
          it { should have_xpath("//input[@value='Follow']") }
        end
      end
    end
  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_title ('Sign up')}
        it { should have_content ('error')}
      end
    end

    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit user") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name", with: new_name
        fill_in "Email", with: new_email
        fill_in "Password", with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end
  end

  describe "profile page" do

    #ユーザーとマイクロポスト×2を作成
    let(:user) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user, content: "Foo") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user, content: "Bar") }

    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }

    #プロフィールページにマイクロポスト×2、ユーザーのマイクロポスト件数が表示されることをテスト
    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }
    end

  end

  #followed_usersページとfollowersページをテスト
  describe "following/followers" do

    #ユーザーを作成
    let(:user) { FactoryGirl.create(:user) }

    #other_userを作成
    let(:other_user) { FactoryGirl.create(:user) }

    #ユーザーがother_userをフォローする
    before { user.follow!(other_user) }

    describe "followed users" do
      before do

        #userとしてサインイン
        sign_in user

        #フォローしているユーザー一覧に遷移
        visit following_user_path(user)
      end

      it { should have_title(full_title('Following')) }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    describe "followers" do

      before do
        #other_userとしてサインイン
        sign_in other_user

        #フォロワー一覧に遷移
        visit followers_user_path(other_user)
      end

      it { should have_title(full_title('Followers')) }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end

  end
end