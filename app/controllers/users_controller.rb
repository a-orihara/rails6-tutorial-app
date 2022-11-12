class UsersController < ApplicationController

  # 8
  # アクションに関してのバリデーション
  # デフォルトでは、beforeフィルターはコントローラ内のすべてのアクションに適用されるので、ここでは適切な:onlyオプ
  # ション(ハッシュ)を渡すことで、:edit と:update アクションだけにこのフィルタが適用されるように制限をかける。
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy


  # GET:/users
  def index
    # 9
    # @userではない
    # 30人で1ページのページネーション.gem 'will_paginate'で使用できる。
    @users = User.paginate(page: params[:page])
  end

  # 1
  def show
    # paramsハッシュのキーがシンボル:idの値を取り出す。
    @user = User.find(params[:id])
    # 2
    # debugger
  end

  def new
    # form_with の引数で必要となる User オブジェクトを作成
    @user = User.new
  end

  def create
    # 3
    @user = User.new(user_params)
    # ↑この書き方は今ではNG→:@user = User.new(params[:user])
    # before_createが発火。有効化トークンセット。
    if @user.save
      # 6 ユーザー登録出来たらそのままログイン状態にする。一時セッション状態になる。
      # ↓11章から下記に変更:log_in @user
      # send_activation_email:deliver_nowでメソッドチェーン.deliver_now:メールを送信する
      @user.send_activation_email
      # 登録完了後に表示 されるページにメッセージを表示。Railsではflash という特殊な変数を使用。
      # ウェルカムメッセージ。flash 変数に代入したメッセージは、リダイレクトした直後のページで表示できるよう になります。
      # ↓11章から下記に変更:flash[:success] = "Welcome to the Sample App!"
      flash[:info] = "Please check your email to activate your account."
      # 5 redirect_to user_url(@user)と等価。/users
      # ↓11章から下記に変更:redirect_to @user
      # mail送信後、リダイレクト先をルートURLに、かつユーザーは以前のようにログインしないように。
      redirect_to root_url
    # 保存の成功をここで扱う。
    else
      render 'new'
    end
  end

  # GET:/users/:id/edit
  # デフォでedit.html.erbへ
  def edit
    # @user = User.find(params[:id])->不要。説明は7へ
  end

  # PATCH:/users/:id
  def update
    # @user = User.find(params[:id])->不要。説明は7へ
    # user_params:Strong Parameters越しのユーザーがインプットした情報(マスアサインメントの脆弱性を防止)
    if @user.update(user_params)
      # 更新に成功した場合を扱う。 
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      # 失敗したらerror object込みで、再度editページへ戻る。だからエラーメッセージが表示される。
      render 'edit'
    end
  end

  # DELETE /users/:id
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    # users_url: /usersの絶対パス。ユーザー一覧へ移動。
    redirect_to users_url
  end

  # 外部から使えないようにします.privateキーワード以降のコードを強調するために、インデントを1段深くしてあります。
  private

    # 4 Strong Parameters
    def user_params
      params.require(:user).permit(:name, :email, :password,:password_confirmation)
    end

    # before アクション
    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
      # ログイン前にアクセスしようとしたURLをsessionのハッシュに[:forwarding_url]キーで保存して覚えておく
      store_location
      flash[:danger] = "Please log in."
      # to /login
      redirect_to login_url
      end
    end

    # 7 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      # unless以外のケースは何もしない
      # current_user?:userがnilならnilを返す。user == currentuserならtrue
      # ↑こういう式user && user == current_user
      redirect_to(root_url) unless current_user?(@user)
    end

    # 管理者かどうか確認
    def admin_user
      # 管理者でなければルートページへリダイレクト
      redirect_to(root_url) unless current_user.admin?
    end

end

# =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =  =   =   =   =
# 1
# @ユーザー表示ビューが正常に動作するためには、Users コントローラ内の show アクションに
# 対応する@user 変数を定義する必要があります。

# @Users コントローラにリクエストが 正常に送信されると、params[:id] の部分は
# ユーザーidの[1]に置き換わります。User.find(1) と同じになります。
# params[:id] は文字列型の"1"ですが、find メソッドでは自動的に整数型 に変換されます。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 2
# *tutorial:リスト 7.6
# debuggerメソッド:コンソールにデバック用のbyebugプロンプトを表示。
# このプロンプトでは Rails コンソールのようにコマンドを呼び出すことができて、
# アプリ ケーションの debugger が呼び出された瞬間の変数の中身等の状態を確認することができます。
# Ctrl-D を押すとプロンプトから抜け出すことができます。
# デバッグが終わっ たら show アクション内の debugger の行を削除してしまいましょう
# 今後 Rails アプリケーションの中でよく分からない挙動があったら、上のようにdebuggerを
# 差し込んで調べてみましょう。トラブルが起こっていそうなコードの近くに差し込むのがコツです。
# byebug gem を使ってシステムの状態を調査することは、アプリケーション内のエラーを追跡したり
# デバッグするときに非常に強力なツールになります。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 3
# params ハッシュには各リクエストの情報が含まれています。ユーザー登録情報 の送信の場合、params
# には複数のハッシュに対するハッシュ(hash-of-hashes: 入れ子に なったハッシュ)が含まれます。
# 例
# "user" => { "name" => "Foo Bar",
#             "email" => "foo@invalid",
#             "password" => "[FILTERED]",
#             "password_confirmation" => "[FILTERED]"
#           }
# *このハッシュのキーが、input タグにあった name属性の値(name="user[name]"とか)になります
# "user[email]"という値は、user ハッシュの:email キーの値と一致します。

# @user = User.new(params[:user])
# イコール：@user = User.new(name: "Foo Bar",
#                          email: "foo@invalid",
#                          password: "foo",
#                          password_confirmation: "bar")

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 4
# Rails はデフォルトでparams ハッシュをまるごと渡すとエラーが発生するので、Railsはマスア
# サインメントの脆弱性から守られるようになりました。
# この場合、params ハッシュでは:user 属性を必須とし、名前、メールアドレス、パス
# ワード、パスワードの確認の属性をそれぞれ許可し、それ以外を許可しないようにします。

# @このコードの戻り値は、許可された属性のみが含まれた params のハッシュです(:user 属性がない場合はエラーになります)。
# これらのパラメータを使いやすくするために、user_params という外部メソッド を使うのが慣習に
# なっています。このメソッドは適切に初期化したハッシュを返し、 params[:user] の代わりとして使われます。
# この user_params メソッドは Users コントローラの内部でのみ実行され、Web 経由で 外部ユーザーに
# さらされる必要はないため、Ruby の private キーワードを使って外部から使えないようにします

# @許可された属性リストに admin が含まれていない。これにより、任意のユーザーが自分自身にアプリケーションの管理者
# 権限を与える ことを防止できます。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 5
# redirect_to user_url(@user)
# これはredirect_to @userというコードからuser_url(@user) といったコードを実行したいという
# ことを、Rails が推察してくれた結果になります。
#/users/:idへのリダイレクトを、相対パスで指定する(1)
# redirect_to("/users/#{@user.id}")
#/users/:idへのリダイレクトを、絶対パスで指定する(2)
# redirect_to("https://228e5b796b37495aa0c17e02856dccfa.vfs.cloud9.us-east-2.amazonaws.com/users/#{@user.id}")
#/users/:idへのリダイレクトを、user_url(id)ヘルパーを使って、絶対パスで指定する(3)
# redirect_to(user_url(@user.id))
#リンクのパスとしてモデルオブジェクトが渡されると自動でidにリンクされるので、.idを省略する(4)
# redirect_to(user_url(@user))
#_urlヘルパーは、省略できる(5)
# redirect_to(@user)
#Rubyでは、()は省略できる(6)
# redirect_to @user

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 6
# def log_in(user)
#   session[:user_id] = user.id
# end
# Sessions コントローラがあることで、Users コントローラで log_in メソッドを使えます。 そのために
# 必要なモジュールはリスト 8.13 (下記[app/controllers/application_controller.rb])で対応しています。
# class ApplicationController < ActionController::Base
#   include SessionsHelper
# end

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 7
# 別のユーザーのプロフィールを編集しようとしたらリダイレクトさせたいので、 correct_user というメソッドを作成し、
# before フィルターからこのメソッドを呼び出 すようにします(リスト 10.25)。before フィルターの correct_user
# で@user 変数を定 義しているため、リスト 10.25 では edit と update の各アクションから、@user への代 
# 入文を削除している点にも注意してください。

# ApplicationControllerでinclude SessionsHelperしているからcurrent_user?が使える
# ログインしてたら一時セッションが貼る。なのでcurrent_userでユーザーが返せる

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 8
# *railsではメソッドを引数に呼ぶ時は、シンボルで呼ぶ場合が多い
# :correct_userのみだとcorrect_userが呼び出せないから、:logged_in_userもbefore_actionで付ける

# @ユーザー を削除するためにはログインしていなくてはならないので、リスト 10.58 では:destroy アクションも 
# logged_in_user フィルターに追加しています。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 9
# paginate では、キーが:page で値がページ番号のハッシュを引数に取ります。 
# [User.paginate(page: 1)]
# User.paginate は、:page パラメー
# ターに基いて、データベースからひとかたまりの データ(デフォルトでは 30)を取り出します。したがって、1 ページ目は
# 1 から 30 の ユーザー、2 ページ目は 31 から 60 のユーザーといった具合にデータが取り出されます。 ちなみに 
# page が nil の場合、 paginate は単に最初のページを返します
# paginate を使うことで、サンプルアプリケーションのユーザーのページネーションを行えるようになります。具体的には、
# index アクション内の User.all を User.paginate メソッド に置き換えます(リスト 10.46)。ここで:page パラメーターには
# params[:page] が使われていますが、これは will_paginate によって自動的に生成されます。