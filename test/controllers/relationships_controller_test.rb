require 'test_helper'

class RelationshipsControllerTest < ActionDispatch::IntegrationTest

  # createはログインユーザーを必要とする
  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      # POST    /relationships
      post relationships_path
    end
    assert_redirected_to login_url
  end

  # 破棄するには、ログインしたユーザが必要とする。
  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      # DELETE  /relationships/:id
      # :one:relationshipのfixturesより
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end
end