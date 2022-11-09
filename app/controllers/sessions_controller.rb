class SessionsController < ApplicationController

  def new
  end

  # sessionのcreateで、sessionを生成するアクション。
  # post:'/login', to: 'sessions#create'
  def create
    # 1
    # usersテーブルから条件に合う最初のレコードを１件取得
    user = User.find_by(email: params[:session][:email].downcase)
    # authenticate:has_secure_passwordが提供するメソッド
    if user && user.authenticate(params[:session][:password])
      # 3 一時セッションを保存（ブラウザ閉じたら無効）
      log_in user
      # チェックボックスがオンのときに’1’ になり、オフのときに’0’ になります。
      # 1:remember(user)で永続セッションを保存。暗号化したuser_idとremember_digestを永続化クッキーに保存。
      # 2:forget(user)で永続セッションを破棄。
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      # 記憶したリクエストしたURL (もしくはデフォルト値[この場合はuser]) にリダイレクト
      redirect_back_or user
    # ユーザーログイン後にユーザー情報のページにリダイレクトする。認証に失敗したときにfalseを返す。
    else
    # エラーメッセージを作成する
    # ↓flash[:danger] = 'Invalid email/password combination'からの、
    # 2
    flash.now[:danger] = 'Invalid email/password combination'
    render 'new'
    end
  end

  def destroy
    # セッションを消去。現在のユーザーをnilに設定。@current_userをnilにする。
    # ログインしていた場合のみログアウト出来る
    log_out if logged_in?
    redirect_to root_url
  end
end

# =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
# 1
# @create アクションの中では、ユーザーの認証に必要なあらゆる情報を params ハッシュから簡単
# に取り出せる。
# ※（form_with(url: login_path, scope: :session, local: true)）で送信されたもの。

# @送信されたメールアドレスを使って、デー タベースからユーザーを取り出しています(6.2.5ではメール
# アドレスをすべて小文字で 保存していたことを思い出しましょう。そこでここでは downcase メソッド
# を使って、有 効なメールアドレスが入力されたときに確実にマッチするようにしています)。

# @&& (論理積(and))は、取得したユーザーが有効かどうかを決定するために使います。
# Ruby では nil と false 以外のすべてのオブジェクトは、真偽値では true になるいう性質を考慮する
# と、入力されたメールアドレスを持つユーザーがデータベースに存在し、かつ入力さ れたパスワードがその
# ユーザーのパスワードである場合のみ、if 文が true になること がわかります。言葉でまとめると「ユー
# ザーがデータベースにあり、かつ、認証に成功した場合にのみ」となります。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 2
# flash[:danger]にすると、次のアクション移行まで表示させる。
# flash.now[:notice]にすると、次のアクションに移行した時点で消える。
# *renderは指定したviewsを呼び出すだけなので、アクションではない。
# *redirect_toは次のアクションになるので、flash.nowだと表示すらしない。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 3
# @[sessions_helper.rb]
# def log_in(user)
#   session[:user_id] = user.id
# end

# @Railsでコードを自動的に変換
# redirect_to @user = redirect_to user_url(@user)
# redirect_to user = redirect_to(user) = redirect_to user_url(user)