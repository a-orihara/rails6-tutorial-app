class CreateMicroposts < ActiveRecord::Migration[6.0]
  # 1
  def change
    create_table :microposts do |t|
      t.text :content
      # 3
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    # 2 複合キーインデックス
    add_index :microposts, [:user_id, :created_at]
  end
end

# =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
# 1
# @rails generate model Micropost content:text user:references
# 今回は生成されたモデルの中に、ユーザーと1対1の関係であることを表す belongs_to のコードも追加されています。
# これは先ほどのコマンドを実行したときに user:references という引数も含めていたからです(リスト 13.1)。

# @User モデルとの最大の違いは references 型を利用している点です。これを利用する と、自動的にインデックスと
# 外部キー参照付きの user_id カラムが追加され*3、User と Micropost を関連付けする下準備をしてくれます
# User モデルのときと同じで、Micropost モデルのマイグレーションファイルでも t.timestamps という行(マジック
# カラム) が自動的に生成されています。これにより、 6.1.1 で説明したように created_at と updated_at という
# カラムが追加されます(図 13.1)。なお、created_at カラムは、13.1.4 の実装を進めていく上で必要なカラムになり
# ます。
# *外部キー参照は、データベースレベルでの制約です。これによって、microposts テーブルの user_id は、users 
# テーブルの id カラムを参照するようになります。本チュートリアルでこの詳細が重要になる ことはありません。また、
# この外部キーによる制約は、すべてのデータベースで使えるわけではありませ ん(例えば Heroku の PostgreSQL 
# ではサポートされていますが、開発用の SQLite ではサポートされてい ません)。外部キーの詳細は 14.1.2 で学びま
# す。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 2
# ＠キーインデックス：よくあるクエリを高速化するのに使う。
# 基本的な使い方はよく引く値があればあらかじめ設定しておくと高速化。6章のメアドのケースは例外
# でユニークにする為に使用。:user_idと:created_atはセットで使うので、予めDBに紐付けを知らせる。

# ＠ここで、リスト 13.3 では user_id と created_at カラムにインデックスが付与されて いることに注目してくださ
# い(コラム 6.2.5)。こうすることで、user_id に関連付けら れたすべてのマイクロポストを作成時刻の逆順で取り出し
# やすくなります。また、user_id と created_at の両方を1つの配列に含めている点にも注目です。こう することで
# Active Record は、両方のキーを同時に扱う複合キーインデックス(Multiple Key Index)作成します。

# 3
# (rails generate model Micropost content:text user:references)
# *1.user:references=user_id:integer(←これを直で書いてもいいけど)。また2.user:referencesで
# belongs_toが付く3.マイグレーションファイルにnull: false, foreign_key: trueが付く。
# foreign_key:これは外部キーがあるとDBに伝えている