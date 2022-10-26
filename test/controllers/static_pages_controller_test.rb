require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @base_title = "Ruby on Rails Tutorial Sample App"
  end


  # 1

  test
    "should get root" do get FILL_IN assert_response FILL_IN
  end

  test "should get home" do
    # アクションを get して正常 に動作することを確認
    get static_pages_home_url
    # success:HTTPのステータスコード(200 OK) を表します
    assert_response :success
    # assert_select:特定のHTMLタグが存在するかどうかをテストする。
    assert_select "title", "Home | #{@base_title}"
  end

  test "should get help" do
    get static_pages_help_url
    assert_response :success
    assert_select "title", "Help | #{@base_title}"
  end

  test "should get about" do
    get static_pages_about_url
    assert_response :success
    assert_select "title", "About | #{@base_title}"
  end

end

# home、helpアクションに合わせて自動生成