# このファイルはrails generate mailerで自動で作成される
# メーラー全体で行いたい処理はここに書く
class ApplicationMailer < ActionMailer::Base
  # 共通の処理・設定を記述する場合にはdefaultメソッドを使用します。
  # from:メールの送信元名 noreplyは慣習。PCが送っていると知らせる。
  default from: "noreply@example.com"
  # デフォルトのレイアウト
  # 'mailer':app/views/layouts/以下のmailer.erb
  layout 'mailer'
end


