require 'test_helper'
class RelationshipTest < ActiveSupport::TestCase

  def setup
    # relationshipのデータを生成
    @relationship = Relationship.new(follower_id: users(:michael).id,
    followed_id: users(:archer).id)
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  # follower_id が必要です。
  test "should require a follower_id" do
    # バリデーション、presenceのテスト
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  # followed_id が必要です。
  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end

end