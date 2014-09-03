class StaticPagesController < ApplicationController

  def home

    #もしサインインしていたら
    if signed_in?

      #_micropost_form.html.erbのインスタンス変数micropostを定義
      @micropost = current_user.microposts.build if signed_in?
      #ユーザーへのサインイン要求を実装し忘れた場合に、テストが失敗して知らせてくれる

      #カレントユーザーの (ページネーション) フィードに@feed_itemsインスタンス変数を追加
      @feed_items = current_user.feed.paginate(page: params[:page])

    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
