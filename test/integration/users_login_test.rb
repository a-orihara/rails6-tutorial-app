require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    # テスト用のユーザー。usersはfixtureのファイル名users.yml を表し、:michael という
    # シンボルはユーザーを参照するためのキーを表します。
    @user = users(:michael)
  end

  # 有効な電子メール/無効なパスワードでログインするテスト
  test "login with valid email/invalid password" do
    get login_path
    # 'sessions/new'urlで描画されるview(登録フォーム送信ページ)が表示されているか
    assert_template 'sessions/new'
    # 無効なパスワードを使用
    post login_path, params: { session: { email:    @user.email,
                                          password: "invalid" } }
    assert_not is_logged_in?
    # ログインできないと、また登録フォームに移動するか
    assert_template 'sessions/new'
    # エラーメッセージが表示されているか
    assert_not flash.empty?
    get root_path
    # エラーメッセージが非表示か
    assert flash.empty?
  end

  # 有効な情報によるログインとログアウトのテスト
  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    # テストユーザーがログイン中の場合にtrueを返す
    assert is_logged_in?
    # assert_redirected_to:リダイレクト先(@user =/users/:id:ユーザー詳細画面)
    assert_redirected_to @user
    #実際にリダイレクト先(ユーザー詳細画面)に移動
    follow_redirect!
    #users/showが描写される
    assert_template 'users/show'
    #assert_select:ページの一部をセレクタで特定して、確認条件が満たされているかどうかを確認。
    #login_pathへのリンクが0である
    assert_select "a[href=?]", login_path, count: 0
    #logout_pathへのリンクがある
    assert_select "a[href=?]", logout_path
    #user_path(@user):/users/:idへのリンクがある
    assert_select "a[href=?]", user_path(@user)
    # 1 logout_path(/logout)へdeleteのリクエスト
    delete logout_path
    # 2 is_logged_in?:テストヘルパーメソッド。テストユーザーがログイン中の場合にtrueを返す
    assert_not is_logged_in?
    assert_redirected_to root_url
    # 2 番目のウィンドウでログアウトをクリックするユーザーをシミュレートする。２つのバグの１つ目の問題
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  # 無効な情報でのログインのテスト
  test "login with invalid information" do
    get login_path
    # 'sessions/new'urlで描画されるviewが表示されているか
    assert_template 'sessions/new'
    # '/login'へparamsハッシュのsessionハッシュの内容のポスト
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    # flashがあればfalseなのでグリーン
    assert_not flash.empty?
    get root_path
    # flashが空かどうか
    assert flash.empty?
  end

  # リメンバー（永続）ありでログイン
  # 2
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    # ログインに成功すれば、cookies 内部の remember_token キーを調べることで、ユーザーが保存
    # されたかどうかをチェックできるようになります。
    assert_not_empty cookies['remember_token']
  end

  # リメンバー（永続）なしでログイン
  test "login without remembering" do
    # クッキーを保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # クッキーを削除してログイン
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
end

# 1
# デストロイアクション
# def destroy
#   # セッションを消去。現在のユーザーをnilに設定。@current_userをnilにする。
#   log_out
#   redirect_to root_url
# end

# 2
# ログインに成功すれば、cookies 内部の remember_token キーを調べることで、ユーザーが保存され
# たかどうかをチェックできるようになります。cookies の値がユーザーの 記憶トークンと一致すること
# を確認できれば理想的なのですが、現在の設計ではテストでこの確認を行うことはできません。コントロ
# ーラ内のuser変数には記憶トークンの属性が含まれていますが、remember_token は実在しない「
# 仮想」のものなので、@user インスタンス変数の方には含まれていません。