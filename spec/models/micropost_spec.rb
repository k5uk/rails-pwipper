require 'spec_helper'

describe Micropost do

  #ユーザーを作成
  let(:user) { FactoryGirl.create(:user) }

  #micropostを正しく書き換え
  before { @micropost = user.microposts.build(content: "Lorem ipsum") }

=begin
  before do

    #micropostを作成
    @micropost = Micropost.new(content: "Lorem ipsum", user_id: user.id)
  end
=end

  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }

  it { should respond_to(:user) }
  its(:user) { should eq user }

  it { should be_valid }

  describe "when user_id is not present" do
    #user_idを空欄にしておく
    before { @micropost.user_id = nil }

    it { should_not be_valid }
  end

  #コンテンツの中身が空っぽだった場合、不正になることをテスト
  describe "with blank content" do
    before { @micropost.content = " " }
    it { should_not be_valid }
  end

  #コンテンツの中身が長すぎた場合、不正になることをテスト
  describe "with content that is too long" do
    before { @micropost.content = "a" * 141 }
                                                         #"a"×141文字の乗算

    it { should_not be_valid }
  end

end