# このファイルはrails generate mailer UserMailerで作成
class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  # 1
  def account_activation(user)
    # userオブジェクトを入れて、メール（ビュー）で使うインスタンス変数を作成
    @user = user
    # 2
    mail to: user.email, subject: "Account activation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset
    @greeting = "Hi"
    mail to: "to@example.org"
  end
end

# 1
# @[ails generate mailer UserMailer account_activation password_rese]でそれぞれ作成

# @コントローラーのアクションと違い、引数が取れる
# コントローラーのアクションは何も記載がないと、デフォのビューがレンダーされるが、メイラーのメソッドはmail
# オブジェクト（text/html）をリターンする。

# このインスタンス変数は、ちょうど普通のビューでコントローラのインスタンス変数を利用できるのと同じように、
# メイラービューで利用できます。

# 2
# 個別の設定にはmailメソッドを使用します。
# mailメソッド.宛先メアドと件名
# account_activationメソッドを呼び出す時に渡されるユーザーの情報から、emailアドレスだけを取り出してメール
# の送信先としてします。
# mailメソッドが呼び出されると、メール本文が記載されているビューが読み込まれます。
# インスタンス変数(@xxx)でメーラービューに値を渡してあげたいので、インスタンス変数を用意してる感じです。

# mailメソッドで利用可能なオプション
# from	送信元メールアドレス
# subject	メールの件名
# to	メールの送信先アドレス 複数の宛先には”,”(カンマ)区切りまたは配列を指定
