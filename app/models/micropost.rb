class Micropost < ApplicationRecord
  # 1 リファレンス型
  # Default:foreign_key: "user_id"になり、それがUserクラスと紐づく
  belongs_to :user
  # 3
  has_one_attached :image
  # 2
  # ↓省略:default_scope -> { self.order(created_at: :desc) }
  default_scope -> { order(created_at: :desc) }
  # presence:はnilの他に半角のスペースもチェックする（ダメを出す）。
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  # 4
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                                      size: { less_than: 5.megabytes,
                                      message: "should be less than 5MB" }
  # 表示用のリサイズ済み画像を返す def display_image
  def display_image
    # 5
    image.variant(resize_to_limit: [500, 500])
  end
end

# =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
# 1
# belongs_toメソッドは、参照元テーブル(外部キーを持つテーブル)から参照先テーブル(主キーを持つテーブル)に
# アクセスする場合に定義します。
# belongs_to :関連名
# 「モデル名はbelongs_toの引数に指定した関連名に属する」という意味になります。belongs_toメソッドを定義
# する事で、参照先(関連する主キーがあるテーブル)の情報が現在のモデルを経由して取得出来る様になります。
# belongs_toメソッドの引数の関連名は単数形になるので注意してください。

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

# データベー スの 2 つのテーブルを繋ぐとき、このような id は外部キー(foreign key)と呼びます。す なわち、
# User モデルに繋げる外部キーが、Micropost モデルの user_id 属性ということ です。この外部キーの名前を
# 使って、Rails は関連付けの推測をしています。具体的には、 Rails はデフォルトでは外部キーの名前を
# <class>_id といったパターンとして理解し、 <class>に当たる部分からクラス名(正確には小文字に変換された
# クラス名)を推測します。
# ただし、先ほどはユーザーを例として扱いましたが、今回のケースではフォローし ているユーザーを follower_id
# という外部キーを使って特定しなくてはなりません。ま た、follower というクラス名は存在しないので、ここでも
# Rails に正しいクラス名を伝え る必要が発生します。
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

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 3
# has_one_attached:指定のモデルと、アップロードされたファイルを関連付けるのに使います。この場合はimageを
# 指定して Micropost モデルと関連付けます。
# このアプリケーションでは「マイクロポスト1件につき画像は1件」という設計を採用していますが、Active Storageで
# はそのほかに has_many_attached オプションも提供して います。これは、Active Record オブジェクト 1 件に
# つき複数のファイルを添付できます。

# Active Storageはファイルアップロードを行うための機能です。これを使えば、フォームで画像の投稿機能などが簡
# 単に作れます。また、Amazon S3などのクラウドストレージサービスに対するファイルのアップロードを簡単に行う
# ことができます。

# :imageはファイルの呼び名で、:photo、:avatar、:hogeなど、ファイルの用途に合わせて好きなものを指定してく
# ださい。ここで、Imageモデルなどを作る必要はないです。Active Storageは裏側でBlobとAttachmentモデルを
# 使って、こそこそとcomment.imageを使えるようにしてくれます。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 4
# gem 'active_storage_validations', '0.8.2'で使用可能なバリデーション

# content_type を検査 することで画像をバリデーションできます。
# { in: %w[image/jpeg image/gif image/png], message: "must be a valid image format" }
# 上のコードは、サポートする画像フォーマットに対応する画像 MIME type をチェックし ます( 6.2.4 で使
#  った配列構築構文 %w[](配列を作成)を思い出しましょう)。
# size: { less_than: 5.megabytes,message: "should be less than 5MB" }
# 上のコードは、画像の最大サイズ を 5 MB に制限しています。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 5
# Active Storage が提供する variantメソッドで変換済み画像を作成できるようにします。特にresize_to_limit
# オプションを用いて、画像の幅や高さが 500 ピクセルを超えることのないように制約をかけます。

# variant によるリサイズは、[app/views/microposts/_micropost.html.erb]でこのメソッドが最初に呼ばれる
# ときにオンデマンドで実行され、以後は結果をキャッシュしますので効率が高まります。
# *もっと大規模なサイトでは、おそらくバックグラウンド処理に任せる方がよいでしょう。この手法は本チュートリアル
# の範疇を超えますが、この方針で進める必要がある場合は、手始めに Active Job を調べる とよいでしょう。
