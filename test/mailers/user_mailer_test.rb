# User メイラーのテスト(Rails による自動生成)

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    user = users(:michael)
    user.activation_token = User.new_token
    # 件名:Account activationのメール(アカウントを有効を促す)を作成。
    # mailオブジェクトが返ってくる。それを変数に格納
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject
    # 送信先を確認
    assert_equal [user.email], mail.to
    # 送信元を確認
    assert_equal ["noreply@example.com"], mail.from
    # 1
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    # CGI モジュールの escape メソッドでメールアドレスの文字列をエスケープ(@を%40に)
    # URIのemail部分のエスケープされた[%40](@)を元に確認
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

end

# 1
# assert_match という非常に強力なメソッドが使われています。これを使えば、正規表現で文字列をテストできます。
# assert_match メソッドを使って名前、有効化トークン、エスケープ済みメールアドレスがメール本文に含まれて
# いるかどうかをテスト