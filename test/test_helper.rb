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
end

# 1
# rails test でminitestを実行する時は、自動的にfixtures/以下が読み込まれます。
# test/test_helper.rb に fixtures :all との記載があると思いますが、こちらが
# テスト実施の際にfixtures/ のファイルをロードしています。