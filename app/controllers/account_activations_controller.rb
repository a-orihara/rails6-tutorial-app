class AccountActivationsController < ApplicationController

  # GET  /account_activation/:id/edit  edit_account_activation_url(token)
  # アプリから送信されたメールの有効化をクリックすると上記をリクエストする。
  def edit
    # emailから探す
    # 2
    user = User.find_by(email: params[:email])
    # !user.activated?: 有効化でなければ. params[:id]でトークンが引っ張れる
    # 1
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # アカウントを有効にする
      user.activate
      # ログイン：一時セッション有効
      log_in user
      flash[:success] = "Account activated!"
      # userページへ redirect_to @userは、redirect_to user_url(@user.id) = /users/#{@user.id}
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      # リダイレクトはルートの絶対パス
      redirect_to root_url
    end
  end

end

# =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
# 1
# @!user.activated?という記述にご注目ください。先ほど「1つ論理値を追加します」 と言ったのはここで利用したい
# からです。このコードは、既に有効になっているユーザー を誤って再度有効化しないために必要です。正当であろうと
# なかろうと、有効化が行われ るとユーザーはログイン状態になります。もしこのコードがなければ、攻撃者がユーザー
# の有効化リンクを後から盗みだしてクリックするだけで、本当のユーザーとしてログイン できてしまいます。そうした
# 攻撃を防ぐためにこのコードは非常に重要です。上の論理値に基いてユーザーを認証するには、ユーザーを認証してから
# activated_at タイムスタンプを更新する必要があります。

# @update_attributes を 1 回呼び出すのではなく、update_attribute を 2 回呼び出していることにご注目くだ
# さい。update_attributes だとバリデーションが実行されてしまうため、今回のようにパス ワードを入力していない
# 状態で更新すると、バリデーションで失敗してしまいます

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 2
# 送られてきたURLパラメーターの中の値は、paramsで取り出せる。
# params[:email]でemail,params[:id]で有効化トークン
# GET  /account_activation/:id/edit  edit_account_activation_url(token)
# つまり  /account_activation/<ここにトークン>/edit
# で、params[:id]で有効化トークンが取り出せる