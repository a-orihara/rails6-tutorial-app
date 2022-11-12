# 自動生成した User メイラーのプレビューファイル。
# このファイル内のメソッドで作られたmailオブジェクトを使って、メールや生成されたURLのプレビューがターミナル
# のログで見れる

# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
# [http://localhost:3000/rails/mailers/user_mailer ですべてのメールをプレビュー]
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at 
  # http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    # user 変数が開発用データベースの最初のユーザーになるように定義(とりあえず最初のユーザーを引っ張っただけ)
    user = User.first
    # [account_activation.text.erb],[ccount_activation.html.erb]ではアカウント有効化のトークンが
    # 必要なので、代入は省略できません。なお、activation_token は仮の属性でしかないの で(11.1)、データ
    # ベースのユーザーはこの値を実際には持っていません。
    user.activation_token = User.new_token
    # UserMailerで定義したメソッドを使いmailオブジェクトを作成
    # account_activation の引数には有効な User オブジェクト を渡す必要がある
    UserMailer.account_activation(user)
  end

  # Preview this email at 
  # http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    user = User.first
    user.reset_token = User.new_token
    UserMailer.password_reset(user)
  end

end
