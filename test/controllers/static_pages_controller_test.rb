# 3
require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  # def setup
  #   @base_title = "Ruby on Rails Tutorial Sample App"
  # end

  # test "should get home" do
  #   # アクションを get して正常 に動作することを確認
  #   get static_pages_home_url
  #   # success:HTTPのステータスコード(200 OK) を表します
  #   assert_response :success
  #   # assert_select:特定のHTMLタグが存在するかどうかをテストする。
  #   assert_select "title", "Home | #{@base_title}"
  # end

  test "should get home" do
    get root_path
    # assert_response:指定されたHTTPステータスが返されたか。
    # success:HTTPのステータスコード(200 OK) を表します
    assert_response :success
    # assert_select:特定のHTMLタグが存在するかどうかをテストする。
    assert_select "title", "Ruby on Rails Tutorial Sample App"
  end

  test "should get help" do
    # help_path -> '/help'
    get help_path
    assert_response :success
    assert_select "title", "Help | Ruby on Rails Tutorial Sample App"
  end

  test "should get about" do
    get about_path
    assert_response :success
    assert_select "title", "About | Ruby on Rails Tutorial Sample App"
  end

  test "should get contact" do
    get contact_path
    assert_response :success
    assert_select "title", "Contact | Ruby on Rails Tutorial Sample App"
  end

end

# 1
# home、helpアクションに合わせて自動生成
# このtestメソッドは文字列(説明文)とブロックを引数にとり、テストが実行されるときにブロック内の文が実行される.

# 2
# 統合テストを使うと、 アプリケーションの動作を端から端まで(end-to-end)シミュレートしてテストすること ができます。

# 3
# require 'test_helper'によってtest/test_helper.rbに記載されているデフォルト設定を読み込みます。
# この記述はテストファイルを作成すると自動で付く。
# また、今後書くすべてのテストにもこれを記述するので、テスト全体で使いたいメソッドは、
# このtest_helper.rbに記述するようにします。