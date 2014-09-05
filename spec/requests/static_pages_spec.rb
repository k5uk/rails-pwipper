require 'spec_helper'

describe "StaticPages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_content(heading) }
    it { should have_title(full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { '' }
    it "should have the right links on the layout" do
      click_link "About"
      expect(page).to have_title(full_title('About Us'))
      click_link "Help"
      expect(page).to have_title(full_title('Help'))
      click_link "Contact"
      expect(page).to have_title(full_title('Contact'))
      click_link "Home"
      click_link "Sign up now!"
      expect(page).to have_title(full_title('Sign up'))
      click_link "sample app"
      expect(page).to have_title(full_title(''))
    end

    it_should_behave_like "all static pages"
    it { should_not have_title('| Home') }

    describe "for signed_in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "hogehoge")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|

          #各フィード項目が固有のCSS idを持つことを前提にしている。
          expect(page).to have_selector("li##{item.id}", text: item.content)
          #上のコードが各アイテムに対してマッチするようにするのが目的
        end
      end

      #Homeページ上の、フォローしているユーザー/フォロワーの統計情報をテスト
      describe "follower/following counts" do

        #other_userを作成
        let(:other_user) { FactoryGirl.create(:user) }

        before do

          #other_userがユーザーをフォロー
          other_user.follow!(user)
          #root_pathに移動
          visit root_path
        end

        #"0 following"という名前でフォローしているユーザー一覧へのリンクが存在するかチェック
        it { should have_link("0 following", href: following_user_path(user)) }

        #"1 followers"という名前でフォローされているユーザー一覧へのリンクが存在するかチェック
        it { should have_link("1 followers", href: followers_user_path(user)) }

        #正しいアドレスへのリンクを確認していることに注目

      end
    end
  end

  describe "Help page" do
    before {visit help_path}
    let(:heading)    { 'Help' }
    let(:page_title) { '' }
  end

  describe "About page" do
    before {visit about_path}
    let(:heading)    { 'About Us' }
    let(:page_title) { '' }
  end

  describe "Contact page" do
    before {visit contact_path}
    let(:heading)    { 'Contact' }
    let(:page_title) { '' }
  end
end