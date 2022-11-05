require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # 1
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     # has_secure_passwordを設定した為
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    # name 属性に対して空白の文字列をセット
    @user.name = " "
    # assert_not:falseであることを検証する
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    # %w:文字列の配列を簡単に作れる
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    #  each メソッドを使って各メールアドレスを順にテスト。
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      # 2
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  # 無効なメールアドレスを使って 「無効性(Invalidity)」についてテスト
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    # dupは、同じ属性を持つデータを複製するためのメソッド
    duplicate_user = @user.dup
    # duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be present (nonblank)" do
    # 多重代入。パスワードとパスワード確認に対して同時に代入。
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  # ダイジェストがnilだったユーザーにはfalseを返すべき。２番めのバグのテスト
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end

end

# 1
# 有効なオブジェクトに対してテストを書くために、setup という特殊なメソッドを使って、
# 有効な User オブジェクト(@user)を作成します。
# setup メソッド内に書かれた処理は、各テストが走る直前に実行 されます。
# @user はインスタンス変数ですが、setup メソッド内で宣言しておけば、
# すべてのテスト内でこのインスタンス変数が使えるようになります。
# したがって、valid?メ ソッドを使って User オブジェクトの有効性をテストすることができます。

# 2
# assertメソッドの第2引数にエラーメッセージを追加。
# これによって、どのメールアドレスでテストが失敗したのかを特定できる。
# inspect:オブジェクトや配列などをわかりやすく文字列で返してくれるメソッド。
# 配列やハッシュの場合は、全体を[]または{}で囲み、各要素をそれぞれinspectメソッドで出力した結果が返ります。
# どのメールアドレスで失敗したのかを知る

# 3
# 通常、メールアドレスでは大文字小文字が区別されません。
# すなわち、foo@bar.com は FOO@BAR.COM や FoO@BAr.coM と書いて も扱いは同じです。
# したがって、メールアドレスの検証ではこのような場合も考慮する必要があります。
# この性質のため、大文字を区別しないでテストすることが重要になります。