require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  # Application ヘルパーを読み込んだことでリスト 4.2 の full_title ヘルパーが利用できる
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  # プロフィールページの表示
  test "profile display" do
    # ユーザーページ
    get user_path(@user)
    # GET     /users/1       show
    assert_template 'users/show'
    # Application ヘルパーを読み込んだ
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    # 2
    assert_select 'h1>img.gravatar'
    # 1
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination'
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end

# 1
# response.body にはそのページの完全な HTML が含まれています(HTML の body タグだけではありません)。
# したがって、そのページのどこかしらにマイクロポストの投 稿数が存在するのであれば、次のように探し出して
# マッチできるはずです。
# [assert_match @user.microposts.count.to_s, response.body]
# assert_matchは assert_select よりもずっと抽象的なメソッドです。特に、assert_select で はどの HTML
# タグを探すのか伝える必要がありますが、assert_match メソッドではそ の必要がない点が違います。

# 2
# cssセレクタの書き方
# assert_select の引数では、ネストした文法を使っている点に も注目してください。
# [assert_select 'h1>img.gravatar']
# h1 タグ(トップレベルの見出し)の内側にある、gravatar ク ラス付きの img タグがあるかどうかをチェックでき
# ます。