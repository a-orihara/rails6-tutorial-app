require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links" do
    get root_path
    # 1
    assert_template 'static_pages/home'
    # assert_select:特定のHTMLタグが存在するかどうかをテストする。
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
  end
end

# 1
# assert_template:指定されたテンプレートが選択されたか
# Rails は自動的にはてなマーク "?" を about_path に置換しています。
# これにより、次のような HTML があるかどうかをチェックすることができます。
# <a href="/about">...</a>