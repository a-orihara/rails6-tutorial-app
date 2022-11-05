require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
    remember(@user)
  end

  # current_user は、セッションが nil のときに正しいユーザーを返す。
  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  # current_user は、記憶しているダイジェストが間違っている場合、nil を返します。
  # 1
  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end


# 1
# ユー ザーの記憶ダイジェストが記憶トークンと正しく対応していない場合に現在のユーザー が nil
# になるかどうかをチェック。これによって、次のネストした if 文内の authenticated?の式を
# テストします。
# [if user && user.authenticated?(cookies[:remember_token])]