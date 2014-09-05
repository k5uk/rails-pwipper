class RelationshipsController < ApplicationController

  before_action :signed_in_user
  #セキュリティ対策。もしサインインしていないユーザーが (curlなどのコマンドラインツールなどを使用して) これらのアクションに直接アクセスするようなことがあれば、current_userはnilになり、どちらのメソッドでも2行目で例外が発生する。

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)

    #Ajaxリクエストに応答
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
    #リクエストの種類に応じて、続く行の中から1つだけが実行されることに注意。
    #Ajaxリクエストを受信した場合は、Railsが自動的にアクションと同じ名前を持つJavaScript組み込みRuby (.js.erb) ファイル (create.js.erbやdestroy.js.erbなど) を呼び出します。

    #ご想像のとおり、これらのファイルではJavaScriptと組み込みRuby (ERb) をミックスして現在のページに対するアクションを実行することができます。

    #ユーザーをフォローしたときやフォロー解除したときにユーザープロファイルページを更新するために、私たちがこれから作成および編集しなければならないのは、まさにこれらのファイルです。

  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)

    #Ajaxリクエストに応答
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end

  end
end