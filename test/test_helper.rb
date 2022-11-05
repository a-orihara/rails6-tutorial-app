ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # [test/fixtures/*.yml にあるすべてのフィクスチャを、アルファベット順にすべてのテストに対してセットアップします。]
  # 1
  fixtures :all
  # Add more helper methods to be used by all tests here...
  # [ここですべてのテストが使用するヘルパーメソッドをさらに追加する...]

  # 2 テストユーザーがログイン中の場合にtrueを返す
  def is_logged_in?
    !session[:user_id].nil?
  end

  # 単体テストの場合は下記、統合テストの場は統合テストのlog_in_asを使用
  # コントローラーの単体テストの場合はsessionが使える。
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest

  # テストユーザーとしてログインする
  # 統合テストの場合はぽpostやgetを使って流れをテストするテスト。なのでsessionを使うより、
  # postメソッドを使ったユーザー操作を模した内容の方が適切.また統合テストではsession を直接取り扱うことができない
  # 3
  def log_in_as(user, password: 'password', remember_me: '1')
    # params{session}の内容でログイン
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end
end

# 1
# rails test でminitestを実行する時は、自動的にfixtures/以下が読み込まれます。
# test/test_helper.rb に fixtures :all との記載があると思いますが、こちらが
# テスト実施の際にfixtures/ のファイルをロードしています。

# 2
# このヘルパーメソッドは、テストのセッションにユーザーがあればtrue を返し、それ以外の場合は
# false を返します(リスト 8.30)。残念ながらヘルパーメソッドはテストから呼び出せないので、
# リスト 8.18 [app/helpers/sessions_helper.rb]のように current_user を呼び出せません。
# session メソッドはテストでも利用できるので、これを代わりに使います。ここでは取り違えを防ぐため、
# logged_in?([[app/helpers/sessions_helper.rb]])の代わりに is_logged_in?を使って、
# ヘルパーメソッド名がテストヘルパーと Session ヘルパーで同じにならないようにしておきます。
# *[app/helpers/sessions_helper.rb]]より
# ユーザーがログインしていれば true、その他なら false を返す
# def logged_in?
#   !current_user.nil?
# end

# 3
# メソッド名は同じ log_in_as ですが、今回は統合テストで扱うヘルパーなので ActionDispatch::IntegrationTest
# クラスの中で定義します。これにより、私たち 開発者は単体テストか統合テストかを意識せずに、
# ログイン済みの状態をテストしたいと きは log_in_as メソッドをただ呼び出せば良い、という
# ことになります
# テストコードがより便利になるように、log_in_as メソッドではキー ワード引数のパスワードと
# [remember me]チェックボックスのデフォ ルト値を、それぞれ’password’ と’1’ に設定