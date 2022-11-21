require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user  = users(:michael)
    @other = users(:archer)
    log_in_as(@user)
  end

  test "following page" do
    # GET /users/:id/following
    get following_user_path(@user)
    # フォローしている他ユーザーが0ではない
    # 1
    assert_not @user.following.empty?
    # フォロー数がボディにあるかどうか
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      # フォローしている他ユーザーページへ飛べるか
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    # GET /users/:id/followers
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  # 従来どおりのテストと、下の Ajax 用のテストの2つ
  # 標準的な方法でユーザをフォローする必要があります。
  test "should follow a user the standard way" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { followed_id: @other.id }
    end
  end

  # Ajaxでユーザーをフォローする必要があります。
  test "should follow a user with Ajax" do
    assert_difference '@user.following.count', 1 do
      # 2
      post relationships_path, xhr: true, params: { followed_id: @other.id }
    end
  end

  # 標準的な方法でユーザーをアンフォローする必要があります。
  test "should unfollow a user the standard way" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      # post メソッドを delete メソッドに置き換えてテストします。
      delete relationship_path(relationship)
    end
  end

  # Ajaxでユーザーをアンフォローする必要がある
  test "should unfollow a user with Ajax" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end

end

# 1
# もし@user.following.empty?の結果がtrueであれば、assert_select 内のブロックが実行されなくなるため、
# その場合においてテストが適切なセキュリティモデルを 確認できなくなることを防いでいます。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 2
# これは標準的なフォローに対するテストではありますが、Ajax 版もやり方は大体同じで す。Ajaxのテストでは、
# xhr :trueオプションを使うようにするだけです。
# ここで使っている xhr(XmlHttpRequest)というオプションを true に設定すると、Ajax でリクエストを発行する
# ように変わります。したがって、リスト 14.36 の respond_to では、JavaScript に対応した行が実行されるよう
# になります。