class Micropost < ApplicationRecord
  # 1 リファレンス型
  belongs_to :user
  # 2
  # ↓省略:default_scope -> { self.order(created_at: :desc) }
  default_scope -> { order(created_at: :desc) }
  # presence:はnilの他に半角のスペースもチェックする（ダメを出す）。
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end

# =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
# 1
# belongs_toはメソッドを作るメソッド
# @belongs_to/has_many 関連付けを使うことで、表 13.1 に示すようなメソッドを Rails で使えるようになります。

# [Micropost.create, Micropost.create!, Micropost.new]ではなく、下記のメソッドを生成する
# micropost.user                  Micropost に紐付いた User オブジェクトを返す
# user.microposts                 User のマイクロポストの集合をかえす
# user.microposts.create(arg)     user に紐付いたマイクロポストを作成する
# user.microposts.create!(arg)    user に紐付いたマイクロポストを作成する(失敗時に例外を発生)
# user.microposts.build(arg)      user に紐付いた新しい Micropost オブジェクトを返す
# user.microposts.find_by(id: 1)  user に紐付いていて、userのid が 1 であるマイクロポストを検索する

# @[user.microposts.create, user.microposts.create!, user.microposts.build]これらのメソッドは使うと、
# 紐付いているユーザーを通してマイクロポストを作成するこ とができます(慣習的に正しい方法です)。新規のマイクロポストが
# この方法で作成され る場合、user_id は自動的に正しい値に設定されます。

# この方法を使うと、例えば次のような
# @user = users(:michael)
# # このコードは慣習的に正しくない
# @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id
# という書き方(リスト 13.4)が、次のように書き換えられます。
# @user = users(:michael)
# @micropost = @user.microposts.build(content: "Lorem ipsum")
# (new メソッドと同様に、build メソッドはオブジェクトを返しますがデータベース には反映されません。)一度正しい
# 関連付けを定義してしまえば、@micropost 変数の user_id には、関連するユーザーの id が自動的に設定されます。
# @user.microposts.build のようなコードを使うためには、User モデルと Micropost モデルをそれぞれ更新して、
# 関連付ける必要があります。Micropost モデルの方では、 belongs_to :userというコードが必要になるのですが、
# これはリスト13.10のマイグ レーションによって自動的に生成されているはずです(リスト 13.10)。一方、User モデ
# ルの方では、has_many :micropostsと追加する必要があります。ここは自動的に生成 されないので、手動で追加して
# ください(リスト 13.11)。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 2
# @:user.microposts メソッドはデフォルトでは読み出しの順序に対して何も保証しませんが、ブログや Twitter の慣
# 習に従って、作成時間の逆順、つまり最も新しいマイクロポ ストを最初に表示するようにしてみましょう*4。これを実
# 装するためには、default scope というテクニックを使います。
# このメソッドは、データベースから要素を取得したときの、デフォルトの順序を指定するメソッ ドです。特定の順序に
# したい場合は、default_scope の引数に order を与えます。例 えば、created_at カラムの順にしたい場合は
# 次のようになります。
# [order(:created_at)]
# ただし、残念ながらデフォルトの順序が昇順(ascending)なっているので、このままで は数の小さい値から大きい値
# にソートされてしまいます(最も古い投稿が最初に表示され てしまいます)。順序を逆にしたい場合は、一段階低いレ
# ベルの技術ではありますが、次 のように生の SQL を引数に与える必要があります。
# [order('created_at DESC')]
# 古いバージョンの Rails では、欲しい振る舞いに するためには生の SQL を書くしか選択肢がなかったのですが、
# Rails 4.0 からは次のよう に Ruby の文法でも書けるようになりました。
# [order(created_at: :desc)]

# @ブロックとは,do~end（もしくは{~}）で囲われた、引数となるためのカタマリ。
# ブロックはそれ単体では存在できず、メソッドの引数にしかなれない。「do~endのカタマリ」がその辺に単体で転がっ
# ているのは見た事ないはず。
# yieldは「ブロックを呼び出すもの」、Procは「ブロックをオブジェクト化したもの」であり、ブロック自体とは別物。
# ブロックをオブジェクト化したものがProc。ブロックがそれ単体では存在できないことを思い出す （→オブジェクト化し
# てしまえばok）。ブロックをオブジェクトに変換することで、引き渡されたメソッド内で扱えるようにする。Procオブジェ
# クトは、callで呼び出すことが出来る。

# @:新たに、ラムダ式(Stabby lambda)という文法を使っています。
# Proc.new{|a, b| a+b }  -書換え>  ->(a, b){a + b}
# これは、Proc や lambda(もしくは無名関数)と呼ばれるオブジェクトを作成する文法です。 
# ->というラムダ式は、ブロック(4.3.2)を引数に取り、Proc オブジェクトを返します。 このオブジェクトは、call 
# メソッドが呼ばれたとき、ブロック内の処理を評価します。

# @default_scopeに{ order(created_at: :desc) }という処理が入る。
# oreder:取得したレコードを特定のキーで並び替える
# 例/Page.order(:category_id):pagesテーブルをcategory_idで並び替える
# /Page.order(:category_id :asc):昇順で並び替える
# default_scope.callで処理を呼び出す。