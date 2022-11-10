require 'test_helper'

# このテストでは、ユーザー登録ボタンを押したときに(ユーザー情報が無効であるため
# に)ユーザーが作成されないことを確認します
class UsersSignupTest < ActionDispatch::IntegrationTest

  # 配列 deliveries は変数なので、setup メソッドでこれを初期化しておかないと、並行して行われる他のテストで
  # メールが配信されたときにエラーが発生してしまいます。別のテストで使ったメールが溜まるのを防止。
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    # 名前付きパス:signup_path -> '/signup'
    get signup_path
    # 1
    assert_no_difference 'User.count' do
      # '/users'
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    # assert_template:後にあるURLがビューを描画しているかをテストする。
    assert_template 'users/new'
  end

  # アカウントアクティベーションを伴う有効なサインアップ情報
  test "valid signup information with account activation" do
    get signup_path
    # 新規ユーザー作成
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    # 送信されたメッセージがきっかり 1 つあるかどうかを確認
    assert_equal 1, ActionMailer::Base.deliveries.size
    # assigns:テストメソッド。対応するアクション内のインスタンス変数にアクセスできる
    # 2
    user = assigns(:user)
    # 作ったばかりなので有効化はしていない
    assert_not user.activated?
    # 有効化していない状態でログインしてみる
    log_in_as(user)
    # ログイン出来ていない（一時セッションがない）
    assert_not is_logged_in?
    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    # follow_redirect:POSTリクエストを送信した結果を見て、指定されたリダイレクト先(つまり
    # 対応するコントローラ内で明示されたリダイレクトの挙動)に移動。
    # この行の直後では’users/show’ テンプレートが表示されているはず
    follow_redirect!
    assert_template 'users/show'
    # is_logged_in?:テストヘルパーメソッド
    assert is_logged_in?
  end

end

# =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
# 1
# assert_difference:第1引数に渡したメソッドの値が、ブロック内で変更されることを検証。
# 第2引数に変更される期待値を渡します。省略した場合は"+1"が期待値になります。
# assert_differenceに似たメソッドとしてassert_no_differenceというメソッドも存在します。
# 式を評価した結果の数値は、ブロックで渡されたものを呼び出す前と呼び出した後で違いがないと主張する。
# このテストは、ユーザ数を覚えた後にデータを投稿してみて、ユーザ数が変わらないか どうかを検証する
# テストになります。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 2
# テストメソッド。
# インスタンス変数に対応するシンボルを渡します。例えばcreateアクションで@userというインスタンス変数が定義
# されていれば、テスト内部ではassigns(:user)と書くことでインスタンス変数にアクセスできます。
# Usersコントローラのcreateアクションの@userインスタンス
# @user = User.new(user_params)のこと。
# 作ったばかりでまだバリデーションを通す前（保存前）の状態のインスタンス.
# 例えば、Users コントローラの create アクションでは@user というインスタンス変数が定義されていますが
# (リスト 11.23)、テストで assigns(:user) と書くとこのインスタンス変数にア クセスできるようになる、と
# いった具合です。なお、この assigns メソッドは Rails 5 以降はデフォルトの Rails テストで非推奨化されて
# いますが、私はこのメソッドは今も 多くの場合に便利であることに気づきました。このメソッドは、リスト 3.2 に
# 含まれる rails-controller-testing という gem を用いることで現在でも利用できます。