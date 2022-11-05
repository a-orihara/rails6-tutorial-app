module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    # 1
    # sessionに[:user_id]という名前をつけてuser.idというを格納
    session[:user_id] = user.id
  end

  def remember(user)
    # userクラスのインスタンスメソッド。
    # 永続セッションを保存。ユーザーのremember_tokenを暗号化したremember_digestをデータベースに記憶する
    user.remember
    # 5 ユーザーID(user_id)を暗号化して（署名付きIDにして）永続クッキーに保存。
    cookies.permanent.signed[:user_id] = user.id
    # 5 [user.remember]で暗号化されたユーザーのremember_tokenを永続クッキーに保存。
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 2 一時セッションがあれば、@current_userを返すメソッド。
  # ログインしてたらログインユーザーの情報を返す
  def current_user
    # 6 もし一時セッションのあるユーザーが存在してれば
    if (user_id = session[:user_id])
      # 3 = @current_user = @current_user || User.find_by(id: session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    # 一時セッションがなければ永続セッション（クッキー）からユーザーを探す
    elsif (user_id = cookies.signed[:user_id])
      # raise
      user = User.find_by(id: user_id)
      # 永続セッション（クッキー）から出したユーザーと記憶ダイジェストを照合
      # userが退会していたら、userが自分でクッキーを削除していたら等、userやクッキーががnilの場合もあるから。&&:nilガードを使用。
      if user && user.authenticated?(cookies[:remember_token])
        # ログイン
        log_in user
        # @current_user生成
        @current_user = user
      end
    end
  end

  # 4 ユーザーがログインしていれば true、その他なら false を返す
  def logged_in?
    !current_user.nil?
  end

  # 現在のユーザーをログアウトする
  def log_out
    # セッションを消去。現在のユーザーをnilに設定。
    session.delete(:user_id)
    # @current_userをnilにする。メモ化しているので、セッションを消しても@current_userがあると困るので。
    @current_user = nil
  end

  # 永続的セッションを破棄する
  def forget(user)
    # forgetの内容:update_attribute(:remember_digest, nil)記憶ダイジェストの消去
    user.forget
    # cookies.delete(:クッキー名 [, 対象のドメイン、またはパス]) 保存されているcookieを削除
    # 署名付きIDを削除
    cookies.delete(:user_id)
    # 記憶トークンを削除
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    # remember_digestをnil、user_id と remember_tokenのcookiesを削除
    forget(current_user)
    # sessionを削除(sessionに入れた暗号化されたuser_idを削除)。
    session.delete(:user_id)
    @current_user = nil
  end
end

# =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
# 1
# Rails で事前定義済みの session メソッドを使って、単純なログインを行えるようにします.
# この session メソッドはハッシュのように扱えるので、次のように代入します。
# session[:user_id] = user.id
# 上のコードを実行すると、ユーザーの[ブラウザ内の一時 cookies ]に暗号化済みのユーザー ID が
# 自動で作成されます。この後のページで、session[:user_id]を使ってユーザー ID を元通りに取
# り出すことができます。一方、cookies メソッド(9.1)とは対照的に、 session メソッドで作成さ
# れた一時 cookies は、[ブラウザを閉じた瞬間に有効期限が終了します]。
# 同じログイン手法を様々な場所で使い回せるようにするために、Sessions ヘルパーに log_in という
# 名前のメソッドを定義することにします。
# session メソッドで作成した一時 cookies は自動的に暗号化され、コードは保護されます。
# 攻撃者がたとえこの情報を cookies か ら盗み出すことができたとしても、それを使って本物のユーザー
# としてログインすることはできないのです。ただし今述べたことは、session メソッドで作成した「一時
# セッ ション」にしか該当しません。cookies メソッドで作成した「永続的セッション」では そこまで断
# 言はできません。永続的な cookies には、セッションハイジャックという攻撃 を受ける可能性が常につ
# きまといます。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 2
# @ユーザー ID を一時セッションの中に保存したら、今度はそのユー ザー ID を別のページで取り出す為に、
# セッション ID に対応するユーザー名をデータベースから取り出し、それをインスタン変数に入れて、その
# インスタンス変数:@current_userを返すメソッド。@current_userは他のページ（viewページ等）で使う。
# ログインした（一時セッションに保存した）ユーザーによって、プロフィール等の表示を変える。

# @user.findではない。
# 代わりに、find メソッドは例外(exception) を発生します。例外はプログラムの実行時に何か例外的
# なイベントが発生したことを示す ために使われます。この場合、存在しない Active Record の id
# によって、find を読み込 んだときに ActiveRecord::RecordNotFound という例外が発生します。
# ユーザー ID が存在しない状態で find を使うと例外が発生してしまいます。find のこの動作は、
# プロフィールページでは適切でした。ID が 無効の場合は例外を発生してくれなければ困るからです。
# しかし、「ユーザーがログイン していない」などの状況が考えられる今回のケースでは、session[:user_id]
# の値は nil になりえます。この状態を修正するために、create メソッド内でメールアドレスの検索に
# 使ったのと同じfind_byメソッドを使うことにします。ただし今度はemailではなく、idで検索します。
# 今度は ID が無効な場合(=ユーザーが存在しない場合)にもメソッドは例外を発生せず、 nil を返します。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 3
# @セッションにユーザー ID が存在しない場合、このコードは単に終了して自動的に nil を 返します。
# これがまさに今欲しい動作なのです。というのも、current_user メソッド が1リクエスト内の処理で
# 何度も呼び出されてしまうと、呼び出された回数と同じだけ データベースへの問い合わせが発生してしまい、
# 結果として処理が完了するまでに時間が かかってしまうからです。
# また、Ruby の慣習に従って、User.find_by の実行結果をインスタンス変数に保存する工夫もしています。
# こうすることで、1リクエスト内におけるデータベースへの問い合 わせは最初の1回だけになり、以後の呼び
# 出しではインスタンス変数の結果を再利用するようになります。地味なようですが、こういった工夫が Web
# サービスを高速化させる重要なテクニックの 1 つです。
# @current_user = @current_user || User.find_by(id: session[:user_id])
# @ここで重要なのは、Userオブジェクトそのものの論理値は常にtrueになることです。そのおかげで、
# @current_user に何も代入されていないときだけfind_by呼び出しが実行され、無駄なデータベース
# への読み出しが行われなくなります。
# @current_user への代入は、Ruby では次のような短縮形で書くのが王道です。
# @current_user ||= User.find_by(id: session[:user_id])

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 4
# 論理値を返す logged_in?メソッドが必要なので、まずはそ れを定義していきましょう。ユーザーがログ
# イン中の状態とは「session にユーザー id が存在している」こと、つまりcurrent_user が nil で
# はないという状態を指します。これをチェックするには否定 演算子(4.2.2)が必要なので、! を使ってい
# きます。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 5
# 例えば、[cookies[:user_id] = user.id]では ID が生のテキストとして cookies に保存されて
# しまう。これを避けるために、署名付き cookie を使います。これは、cookie をブラウザに保存する
# 前に安全に暗号化するためのものです。
# [cookies.signed[:user_id] = user.id]
# ユーザー ID と記憶トークンはペアで扱う必要があるので、cookie も永続化しなくてはな りません。
# そこで、次のように signed と permanent をメソッドチェーンで繋いで使います。
# [cookies.permanent.signed[:user_id] = user.id]
# cookies を設定すると、以後のページのビューでこのように cookies からユーザーを取り出せるように
# なります。
# [User.find_by(id: cookies.signed[:user_id])]
# ↑cookies.signed[:user_id]では自動的にユーザーIDのcookiesの暗号が解除され、元に戻ります。

# 6
# 永続セッションの場合は、session[:user_id] が存在すれば一時セッションからユー ザーを取り出し、
# それ以外の場合は cookies[:user_id] からユーザーを取り出して、 対応する永続セッションにログイ
# ンする。

# このコードを言葉で表 すと、「ユーザー ID がユーザー ID のセッションと等しければ...」ではなく、
# 条件式ではなく、nillの有無を確かめる「(ユーザー ID にユーザー ID のセッションを代入した結果)ユーザー ID のセッションが存在すれば」
#  となります。（）はなくてもいいが、わかりやすくするため付けている。