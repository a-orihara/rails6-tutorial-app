class UsersController < ApplicationController

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
    # ↑この書き方は今ではNG:@user = User.new(params[:user])
    if @user.save
      # 登録完了後に表示 されるページにメッセージを表示。Railsではflash という特殊な変数を使用。
      # ウェルカムメッセージ。flash 変数に代入したメッセージは、リダイレクトした直後のページで表示できるよう になります。
      flash[:success] = "Welcome to the Sample App!"
      # 5 redirect_to user_url(@user)と等価。/users
      redirect_to @user
    # 保存の成功をここで扱う。
    else
      render 'new'
    end
  end

  # 外部から使えないようにします.privateキーワード以降のコードを強調するために、インデントを1段深くしてあります。
  private

    # 4 Strong Parameters
    def user_params
      params.require(:user).permit(:name, :email, :password,:password_confirmation)
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
