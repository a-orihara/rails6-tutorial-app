class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  # 1
  # POST   /microposts    create   microposts_path
  def create
    # User/Micropost 関連付けを使ってbuildメソッドを使用
    # 関連付けを行っているので、user_idは送られる必要がない。contentだけでOK
    @micropost = current_user.microposts.build(micropost_params)
    # 4
    # マイクロポストのイメージにviewから送信した[:micropost][:image]をくっつける
    @micropost.image.attach(params[:micropost][:image])
    # バリデーションが走ってsave
    if @micropost.save
      flash[:success] = "Micropost created!"
      # static_pages#home
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      # ログイン済みのユーザーのホームページ
      render 'static_pages/home'
    end
  end

  # DELETE /microposts/1  destroy  micropost_path(micropost)
  # 2
  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    # 3 一つ前のページかルートに戻る(どのページから消してもいいように)
    redirect_to request.referrer || root_url
  end

  private

  # micropost_params で Strong Parameters を使っていることにより、マイクロポストの content 属性だけ
  # が Web 経由で変更可能
    def micropost_params
      params.require(:micropost).permit(:content, :image)
    end

    # DELETE /microposts/1  destroy:ここから来た(id: params[:id])
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end

# 1
# 第 7 章では、HTTP POST リクエストを Users コントローラの create アクションに発 行する HTML フォームを
# 作成することで、ユーザーのサインアップを実装しました。マイ クロポスト作成の実装もこれと似ています。主な違い
# は、別の micropost/new ページを使 う代わりに、ホーム画面(つまりルートパス)にフォームを置くという点です。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 2
# before_actionの:correct_userで投稿所有ユーザーか事前に確認.
# correct_user フィルター内で find メソッドを呼び出すことで、現在のユーザーが削除対象のマイクロポストを保
# 有しているかどうかを確認します。
# これにより、あるユーザーが他のユーザーのマイクロポストを削 除しようとすると、自動的に失敗するようになります。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 3
# request.referrer:フレンドリーフォワーディングの request.url 変数(10.2.3)と似ていて、一つ前のURLを
# 返します(今回の場合、Home ページになります)。 を返します(今回の場合、Home ページになります)。このため、
# マイクロポストがHome ページから削除された場合でもプロフィールページから削除された場合でも、 request.referrer
# を使うことで DELETE リクエストが発行されたページに戻すこと ができるので、非常に便利です。ちなみに、元に戻す
# URL が見つからなかった場合で も(例えばテストでは nil が返ってくることもあります)、リスト 13.53 の||演算子
# で root_url をデフォルトに設定しているため、大丈夫です。
# *これは、HTTP の仕様として定義されている HTTP_REFERER と対応しています。ちなみに「referer」は 誤字では
# ありません。HTTP の仕様では、確かにこの間違ったスペルを使っているのです。一方、Rails は「referrer」とい
# う正しいスペルで使っています。
# *リファラーとは、参照元のことを意味します。もう少し言うと、サイト訪問したユーザーが1つ前に閲覧したWebサイト
# （Webページ）のこと

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 4
# Actuve Storageでmicropostモデルに:imageを追加したので、この表記(@micropost.image)が使える。
# アタッチするだけ。DBに保存しているわけではない。この後の@micropost.saveで保存される

# 新たに作成した micropost オブジェクト に画像を追加できるようにします。Actuve Storage API にはそのため
# の attach メソッドが提供されていますので、これを使って行えます。具体的には、Microposts コントローラの
# create アクションの中で、アップロードされた画像を@micropost オブジェクトに アタッチします。このアップロ
# ードを許可するために、micropost_params メソッドを 更新して:image を許可済み属性リストに追加し、Web 経
# 由で更新できるようにする必要 もあります。
# 一度画像がアップロードされれば、micropost パーシャルの image_tag ヘルパーを用いて、関連付けられた
# micropost.image を描画(レンダリング)できるようになります (リスト 13.62)。
