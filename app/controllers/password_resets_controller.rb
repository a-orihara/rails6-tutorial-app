class PasswordResetsController < ApplicationController

  # 下記3つで11章の[account_activations_controller]のeditアクションに相当する確認用のメソッドをbefore_actionで設定
  # 複数のアクションでユーザー取得と認証を行う為
  # :get_user:ユーザーを取得してくる処理
  before_action :get_user,   only: [:edit, :update]
  # :valid_user:ユーザーを認証する処理
  before_action :valid_user, only: [:edit, :update]
  # 1. パスワード再設定の有効期限が切れていないか、への対応
  before_action :check_expiration, only: [:edit, :update]

  # GET   /password_resets/new  new  new_password_reset_path
  def new
  end

  # POST  /password_resets  create  password_resets_path = /password_resets
  # create:再設定トークン、ダイジェストを作成、パスワード再設定用のメールを送信
  def create
    # form_withのscopeが[:password_reset]
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      # [パスワードの再設定方法を記載したメールを送信]
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      # to /password_resets/new
      render 'new'
    end
  end

  # GET   /password_resets/トークン/edit:送られたパスワード再設定のメールをクリック
  # 中身はbefore_actionで設定
  def edit
  end

  # 1
  def update
    # 3. 新しいパスワードが空文字列になっていないか(ユーザー情報の編集ではOKだった)、への対応
    # ユーザーが打ち込んだ、送信したパスワードをチェック
    if params[:user][:password].empty?
      # @user オブジェクトにエラーメッセージを追加
      # パスワードが空だった時に空の文字列に対するデフォルトのエラーメッセージを表示
      @user.errors.add(:password, :blank)
      # 編集ページへ
      render 'edit'
    # 4. 新しいパスワードが正しければ、更新する、への対応
    elsif @user.update(user_params)
      # ログイン、一時セッションを貼る
      log_in @user
      flash[:success] = "Password has been reset."
      # ユーザーページへ
      redirect_to @user
    else
      # 2. 無効なパスワードであれば失敗させる(失敗した理由も表示する)、への対応
      render 'edit'                                  
    end
  
  end

  private

    # ストロングパラメーター：password と password_confirmation 属性を精査
    # admin:trueとかにしないよう対処
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # edit アクションと update アクションのどちらの場合も正当な@userが存在する必要がある
    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 有効なユーザーかどうか確認する
    def valid_user
      # activated?:真偽値を設定したので自動でrailsが設定、authenticated?:トークンがダイジェストと一致したらtrueを返す。
      unless (@user && @user.activated? &&
              # 再設定トークンとそのダイジェストを認証
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # トークンが期限切れかどうか確認する
    def check_expiration
      # User モデルで 定義。password_reset_expired?:期限切れならtrue
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        # [/password_resets/new](自分のメアドを入力する画面)へリダイレクト
        redirect_to new_password_reset_url
      end
    end

end

# =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
# 1
# update アクションでは、次の4つのケースを考慮する必要があります。
# 1. パスワード再設定の有効期限が切れていないか
# 2. 無効なパスワードであれば失敗させる(失敗した理由も表示する)
# 3. 新しいパスワードが空文字列になっていないか(ユーザー情報の編集ではOKだった)
# 4. 新しいパスワードが正しければ、更新する
# 今回の小難しい問題点は、パスワードが空文字だった場合の処理です。というのも、以前 User モデルを作っていた
# ときに、パスワードが空でも良い(リスト 10.13 の allow_nil) という実装をしたからです。したがって、この
# ケースについては明示的にキャッチする コードを追加する必要があります。
# ＊この場合、[パスワードフィールド]が空である場合だけを扱います。[パスワードの確認フィールド]が空の場合は、
# 確認フィールドのバリデーションで検出され、エラーメッセージが表示されるので不要です。ただし、パスワードフィ
# ールドとパスワード確認フィールドが両方空だとバリデーションがスキップされてしまいます。
# 今回は@user オブジェクトにエラーメッセージを追 加する方法をとってみます。具体的には、次のように errors.add を
# 使ってエラーメッ セージを追加します。