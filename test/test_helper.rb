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