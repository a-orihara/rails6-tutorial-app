require 'test_helper'

# このテストでは、ユーザー登録ボタンを押したときに(ユーザー情報が無効であるため
# に)ユーザーが作成されないことを確認します
class UsersSignupTest < ActionDispatch::IntegrationTest

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

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    # follow_redirect:POSTリクエストを送信した結果を見て、指定されたリダイレクト先(つまり
    # 対応するコントローラ内で明示されたリダイレクトの挙動)に移動。
    # この行の直後では’users/show’ テンプレートが表示されているはず
    follow_redirect!
    assert_template 'users/show'
  end

end

# 1
# assert_difference:第1引数に渡したメソッドの値が、ブロック内で変更されることを検証。
# 第2引数に変更される期待値を渡します。省略した場合は"+1"が期待値になります。
# assert_differenceに似たメソッドとしてassert_no_differenceというメソッドも存在します。
# 式を評価した結果の数値は、ブロックで渡されたものを呼び出す前と呼び出した後で違いがないと主張する。
# このテストは、ユーザ数を覚えた後にデータを投稿してみて、ユーザ数が変わらないか どうかを検証する
# テストになります。
