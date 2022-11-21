class RelationshipsController < ApplicationController

  before_action :logged_in_user

  # 1
  # POST  /relationships
  def create
    # followボタンで送信されたパラメータを使って、followed_idに対応するユーザーを見つけてくる
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    # respond_toメソッドとは、ブラウザからリクエストで指定されたフォーマットによって処理を分ける事が出来るメソッド。
    # format.形式 { 処理 }
    respond_to do |format|
      # リクエストされるフォーマットがHTML形式の場合
      format.html { redirect_to @user }
      # リクエストされるフォーマットがJSファイルの場合
      # 何も指定がない場合、デフォ[app/views/relationships/create.js.erb]がレンダーされる
      format.js
    end
  end

  # DELETE  /relationships/:id
  def destroy
    # ユーザーがフォローしている他ユーザーを代入
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

end

# 1
# フォーム(リスト 14.21 とリ スト 14.22)から送信されたパラメータを使って、followed_id に対応するユーザー
# を見つけてくる必要があります。その後、見つけてきたユーザーに対して適切に follow/unfollow メソッド
# (リスト 14.10)を使います。

# もしログインしていないユーザーが(curl などの コマンドラインツールなどを使って)これらのアクションに直接アク
# セスするようなこと があれば、current_user は nil になり、どちらのメソッドでも 2 行目で例外が発生します。
# エラーにはなりますが、アプリケーションやデータに影響は生じません。このまま でも支障はありませんが、やはり
# このような例外には頼らない方がよいので、上ではひと 手間かけてセキュリティのためのレイヤーを追加しました。
