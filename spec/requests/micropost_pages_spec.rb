require 'spec_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post"}
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before {fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end
  end

  #Micropostsコントローラのdestroyアクションをテスト
  describe "micropost destruction" do

    #factorygirlを使ってマイクロポストとユーザーを作成
    before { FactoryGirl.create(:micropost, user: user) }

    #正しいユーザーだったらroot_path(home)にアクセスする。
    describe "as correct user" do
      before { visit root_path }

      #削除ボタンを押されたらマイクロポストのカウントが1減る
      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end
  end
end
