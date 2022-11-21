class Relationship < ApplicationRecord
  # 1
  # :followerという名前で関連づけ。railsはfollower_idを外部キーと認識。
  # でもデフォだと関連名からrailsはFollowerクラスを探すので、Userクラスを手動で指定
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end

# 1
# followerメソッドを生成。
# a = Relationship.first
# a.follower
# で、Relationshipのidが1のfollowerのユーザー情報を返す

# 外部キーfollower_id(モデル名_id)をクラスUserと紐付け。class_name: "User"がないと、
# railsはFollowerクラスを探しに行ってしまう

# belongs_toメソッドは、参照元テーブル(外部キーを持つテーブル)から参照先テーブル(主キーを持つテーブル)に
# アクセスする場合に定義します。
# belongs_to :関連名
# 「モデル名はbelongs_toの引数に指定した関連名に属する」という意味になります。belongs_toメソッドを定義
# する事で、参照先(関連する主キーがあるテーブル)の情報が現在のモデルを経由して取得出来る様になります。
# belongs_toメソッドの引数の関連名は単数形になるので注意してください。
# この関連名をを元にメソッドを作成
# 関連名からrailsは外部キーを探す？