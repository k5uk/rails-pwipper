class MicropostsController < ApplicationController
  before_action :signed_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  #Micropostsコントローラのアクションに認証を追加
  before_action :signed_in_user
  #before_actionはデフォルトで両方のアクションに適用されるため、制限を適用するアクションを明示していないことに注意

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else

      # (空の) @feed_itemsインスタンス変数を追加
      @feed_items = []

      render 'static_pages/home'
    end
  end

  #マイクロポストを削除するためのアクション
  def destroy
    @micropost.destroy
    redirect_to root_url
  end

  private

    #micropost_paramsでStrong Parametersを使用していることにより、マイクロポストのコンテンツだけがWeb経由で編集可能
    def micropost_params
      params.require(:micropost).permit(:content)
    end

    #before_actionのためのcorrect_userアクション
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      #これによって、カレントユーザーに所属するマイクロポストだけが自動的に見つかることが保証される。この場合、findではなくfind_byを使用する。これは、前者ではマイクロポストがない場合に例外が発生しますが、後者はnilを返すため。
      redirect_to root_url if @micropost.nil?
    end

end