require 'spec_helper'

describe Relationship do

  #リレーションシップの作成と属性のテスト
  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  let(:relationship) { follower.relationships.build(followed_id: followed.id) }
  #letを使用してインスタンス変数にアクセスしていることに注目。動作をよりはっきりとさせるために、インスタンス変数を使用する際にはletを使用したほうがいい。

  subject { relationship }

  it { should be_valid }

  #ユーザー/リレーションシップのbelongs_to関連付けをテスト
  describe "follower methods" do
    it { should respond_to(:follower) }
    it { should respond_to(:followed) }
    its(:follower) { should eq follower }
    its(:followed) { should eq followed }
  end

  #Relationshipモデル検証のテスト
  describe "when followed id is not present" do

    #relationshipのfollowed_id（フォローしているユーザーID）を空にする
    before { relationship.followed_id = nil }

    #不正になるべき
    it { should_not be_valid }
  end

  describe "when follower id is not present" do
    #relationshipのfollower_id（フォローされているユーザーID）を空にする
    before { relationship.follower_id = nil }

    #不正になるべき
    it { should_not be_valid }
  end
end
