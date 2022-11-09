require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  # 編集失敗
  test "unsuccessful edit" do
    log_in_as(@user)
    # edit_user_path(@user):/users/#{@userのuserページ}/edit
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }

    assert_template 'users/edit'
  end

  # 編集成功
  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name  = "Foo Bar"
    email = "foo@bar.com"
    # 1
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              # パスワードが空でも成功
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end

  # フレンドリーフォワーディングで編集に成功
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    # ログインせずに直接editページに行くとログインページへ飛ぶ、からのログイン
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
end

# 1
# パスワードとパスワード確認が空であることに注目してください。ユーザー名やメールアドレ スを編集するときに
# 毎回パスワードを入力するのは不便なので、(パスワードを変更する 必要が無いときは)パスワードを入力せずに
# 更新できると便利です。また、6.1.5 で紹介 した@user.reload を使って、データベースから最新のユーザー
# 情報を読み込み直して、 正しく更新されたかどうかを確認している点にも注目してください。(こういった正しい
# 振る舞いというのは一般に忘れがちですが、受け入れテスト(もしくは一般的なテスト駆 動開発)では先にテスト
# を書くので、効果的なユーザー体験について考えるようになり ます。)