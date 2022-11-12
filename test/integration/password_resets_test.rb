require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  # 配列 deliveries は変数なので、setup メソッドでこれを初期化しておかないと、並行して行われる他のテストで
  # メールが配信されたときにエラーが発生してしまいます。別のテストで使ったメールが溜まるのを防止。
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  # 1
  test "password resets" do
    # GET /password_resets/new
    get new_password_reset_path
    assert_template 'password_resets/new'
    # input タグに正しい名前、type="hidden"、メールアドレスがあるかどうか を確認
    # <input name=?(値はなんでも) />
    assert_select 'input[name=?]', 'password_reset[email]'

    # メールアドレスが無効
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'

    # メールアドレスが有効
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    # 送信されたメッセージがきっかり 1 つあるかどうかを確認
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    # パスワード再設定フォームのテスト
    user = assigns(:user)

    # メールアドレスが無効
    # GET /password_resets/トークン/edit
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url

    # 無効なユーザー
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)

    # メールアドレスが有効で、トークンが無効
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url

    # メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    # input タグに正しい名前、type="hidden"、メールアドレスがあるかどうか を確認
    # <input id="email" name="email" type="hidden" value="michael@example.com" />
    assert_select "input[name=email][type=hidden][value=?]", user.email

    # 無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'

    # パスワードが空
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'

    # 有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
end

# =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
# 1
# 最初に 「forgot password」フォームを表示して無効なメールアドレスを送信し、次はそのフォー ムで有効なメー
# ルアドレスを送信します。後者ではパスワード再設定用トークンが作成さ れ、再設定用メールが送信されます。続い
# て、メールのリンクを開いて無効な情報を送信 し、次にそのリンクから有効な情報を送信して、それぞれが期待どお
# りに動作することを 確認します。