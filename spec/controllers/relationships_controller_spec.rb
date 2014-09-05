#RelationshipsコントローラがAjaxリクエストに応答することをテスト。結合テストの観点からコントローラ向けのテストは控えている。ただし、どういうわけかこの場合xhrメソッドを結合テストで使用することができないために、このコントローラでのテストを行なっている。

require "spec_helper"

describe RelationshipsController do

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before { sign_in user, no_capybara: true }

  describe "creating a relationship with Ajax" do

    it "should increment the Relationship count" do
      expect do
        xhr :post, :create, relationship: { followed_id: other_user.id }
        #xhrが取る引数は、関連するHTTPメソッドを指すシンボル、アクションを指すシンボル、またはコントローラ自身にあるparamsの内容を表すハッシュのいずれかです。これまでの例と同様、expectを使用してブロック内の操作をまとめ、関連するカウントを1増やしたり減らしたりするテストを行なっています。

        #このテストが暗に示していfるように、実はこのアプリケーションコードがAjaxリクエストへの応答に使用するcreateアクションとdestroyアクションは、通常のHTTP POSTリクエストとDELETEリクエストに応答するのに使用されるのと同じものです。これらのアクションは、11.2.4のようにリダイレクトを伴う通常のHTTPリクエストと、JavaScriptを使用するAjaxリクエストの両方に応答できればよいのです。

      end.to change(Relationship, :count).by(1)
    end

    it "should respond with success" do
      xhr :post, :create, relationship: { followed_id: other_user.id }
      expect(response).to be_success
    end
  end

  describe "destroying a relationship with Ajax" do

    before { user.follow!(other_user) }
    let(:relationship) do
      user.relationships.find_by(followed_id: other_user.id)
    end

    it "should decrement the Relationship count" do
      expect do
        xhr :delete, :destroy, id: relationship.id
      end.to change(Relationship, :count).by(-1)
    end

    it "should respond with success" do
      xhr :delete, :destroy, id: relationship.id
    end
  end
end