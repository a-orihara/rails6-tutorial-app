require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  # ページネーションと削除リンクを含む管理者向けインデックス
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    # users_path:/usersへのget=indexアクション
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    # ユーザーが一人減っている
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  # 非管理者用インデックス
  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  # # ページングを含むインデックス
  # test "index including pagination" do
  #   log_in_as(@user)
  #   # users_path:/users
  #   get users_path
  #   assert_template 'users/index'
  #   # divタグのpaginationクラス
  #   assert_select 'div.pagination'
  #   User.paginate(page: 1).each do |user|
  #     # user_path:/users/#{user_id}
  #     assert_select 'a[href=?]', user_path(user), text: user.name
  #   end
  # end

end