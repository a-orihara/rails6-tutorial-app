require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect edit when not logged in" do

    # /users/1/edit
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    # PATCH:/users/:id -> updateアクションになる
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # 非ログイン時にインデックスをリダイレクトするようにする
  test "should redirect index when not logged in" do
    # users_path:/users
    get users_path
    assert_redirected_to login_url
  end

  # 非ログイン時に更新をリダイレクトする
  # test "should redirect update when not logged in" do
  #   get edit_user_path(@user)
  #   # patch user_path(@user), params: { user: { name: @user.name,
  #   #                                           email: @user.email } }
  #   assert_not flash.empty?
  #   assert_redirected_to login_url
  # end

  # 間違ったユーザでログインしたときに編集をリダイレクトする
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    # 既にログイン済みのユーザーを対象としているため、ログインページではなくルート URL にリダイレクトしている
    # userコントローラーのcorrect_userメソッドでルートに弾かれる
    assert_redirected_to root_url
  end

  # 間違ったユーザーでログインした場合、更新をリダイレクトする
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    # userコントローラーのcorrect_userメソッドでルートに弾かれる
    assert_redirected_to root_url
  end

  # 非ログイン時にでdestroyアクションを（ログインページへ）リダイレクトする
  test "should redirect destroy when not logged in" do
    # destroyしてもユーザーの数が変わらない
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    # ログインページへ
    assert_redirected_to login_url
  end

  # 非管理者としてログインしたときに、destroyアクションをルートページへリダイレクトする。
  test "should redirect destroy when logged in as a non-admin" do
    # 非管理者としてログイン
    log_in_as(@other_user)
    # destroyしてもユーザーの数が変わらない
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    # ルートページへ
    assert_redirected_to root_url
  end

  # ログインしていない場合、以下のようにリダイレクトする必要があります。
  test "should redirect following when not logged in" do
    # GET /users/1/following (ユーザーがフォローしている他ユーザーの集合を一覧表示するページ)
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  # ログインしていないときにフォロワーをリダイレクトするようにする。
  test "should redirect followers when not logged in" do
    # GET  /users/1/followers
    get followers_user_path(@user)
    assert_redirected_to login_url
  end

end