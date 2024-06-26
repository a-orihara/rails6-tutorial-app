# 1

class User < ApplicationRecord

  # 15
  # has_many :関連名(名前は任意。複数形になるので注意)
  # railsはモデルのMicropostクラスを探す。
  # Default:class_name: "Micropost"になる
  # Default:foreign_key: "user_id"になる
  has_many :microposts, dependent: :destroy

  # 17
  # 能動側。指定しているので、railsはモデルのRelationshipクラスを探す
  has_many :active_relationships, class_name: "Relationship",
                                  # user_idにしないため
                                  foreign_key: "follower_id",
                                  # userクラスが削除されたら紐づいて自分がフォローしているのが消える
                                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy
  
  # 18 シンボルが引数だと、メソッド(active_relationships,followed)を呼び出している。
  # active_relationshipsは上で、followedは[models/relationship.rb]で定義されている
  # has_manyでfollowing_idsも生成
  has_many :following, through: :active_relationships, source: :followed
  # 19
  has_many :followers, through: :passive_relationships, source: :follower

  # 8 DBとは連携しない仮属性としてremember_token、activation_token属性を生成
  attr_accessor :remember_token, :activation_token, :reset_token

  # 4
  # ↓11章で下記に書き換え:before_save { self.email = email.downcase }。このコードは明示的にブロックを渡している。
  # オブジェクトが保存される直前、オブジェクトの作成時や更新時に発火。
  before_save :downcase_email

  # 12
  # オブジェクトの作成時のみ発火。つまりユーザーを新規登録した瞬間
  # before_saveだとプロフィール更新時にも発火してしまう。
  before_create :create_activation_digest

  # validatesはメソッド。presence: true という引数は、要素が1つのオプションハッシュです。
  # メソッドの最後の引数としてハッシュを渡す場合、波カッコを付けなくても問題ありません。validates(:name, presence: true)。
  validates :name, presence: true, length: { maximum: 50 }

  # 定数です。大文字で始まる名前は Ruby では定数を意味します。
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
                    # 3
                    # uniqueness: { case_sensitive: false }

  # 5
  # セキュアにハッシュ化したパスワードを、データベース内のpassword_digestという属性に保存。
  has_secure_password
  # 11
  # :allow_nilオプションは、対象の値がnilの場合にバリデーションをスキップします。
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す.テスト用ユーザーのパスワード生成の為に作成。
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # 6 ランダムなトークンを返す
  def User.new_token
    # A–Z、a–z、0–9、"-"、"_"のいずれかの文字(64 種類)からなる長さ22のランダムな文字列を返します
    SecureRandom.urlsafe_base64
  end

  # 7 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    # ランダムなトークンをuserモデルのremember_token属性に追加
    self.remember_token = User.new_token
    # 9記憶ダイジェストを更新。このメソッドはバリデーションを素通りさせます。
    # self.update_attributeでもいい。
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 14
  # トークンがダイジェストと一致したら true を返す。動的ディスパッチ。 
  def authenticated?(attribute, token)
    # selfは省略可能:digest = self.send("#{attribute}_digest")
    # 全てのオブジェクトにsendメソッドあり
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # 10 ユーザーのログイン情報を破棄する。記憶ダイジェストの消去。
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    update_attribute(:activated,    true)
    # Time.zone.now:今の時間を刻む
    update_attribute(:activated_at, Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    # account_activation:有効化メールのmailオブジェクトを作成
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    # 再設定トークンをセット
    self.reset_token = User.new_token
    # 再設定トークンをハッシュ化して再設定ダイジェストにセット
    update_attribute(:reset_digest, User.digest(reset_token))
    # パスワード再設定の属性を設定した時間を記録
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限2時間以上が切れている場合はtrueを返す
  def password_reset_expired?
    # < 記号を「~現在時刻により早い（近い）時刻」と読んでください。
    # パスワード再設定メールの送信時刻が、現在時刻より2時間以上前(早い)の場合
    # 例/現在時刻:15時、パスワード再設定:12時、15時より2時間以上前:13時
    # selfは省略可能:↓self.reset_sent_at
    reset_sent_at < 2.hours.ago
  end

  # 16
  # 現在ログインしているユーザーのマイクロポストをすべて取得
  def feed
    # user_idにはidが入る idはself.idの省略
    # ↓14章で下記に変更:Micropost.where("user_id = ?", id)
    # ↓からのMicropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    # ↓からのMicropost.where("user_id IN (:following_ids) OR user_id = :user_id",
                    # following_ids: following_ids, user_id: id)
    # 20
    following_ids = "SELECT followed_id FROM relationships
                    WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                    OR user_id = :user_id", user_id: id)
  end

  # ユーザーをフォローする 
  # フォローしているユーザーを配列の様に扱えるため（リスト 14.8 ）。<<演算子(Shovel Operator)で配列の最後に追記
  def follow(other_user)
    # followingの返り値は、フォローしているユーザーの配列
    following << other_user
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 現在のユーザーがフォローしてたら true を返す
  def following?(other_user)
    following.include?(other_user)
  end

  # ユーザーモデル以外で使わないメソッド
  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # メールアドレスをすべて小文字にする 
    def downcase_email
      self.email = email.downcase
    end

    # 13 有効化トークンと有効化ダイジェストを作成および代入する
    def create_activation_digest
      # activation_token=: セッターメソッド
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end

# 1
# class User < ApplicationRecord という構文で、ApplicationRecordを継承するので、
# Userモデルは自動的にActiveRecord::Base クラスのすべての機能を持つことになります。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 2
# オプションは引数に正規表現(Regular Expression)(regex とも呼ばれます)を取ります。
# 正規表現は一見謎めいて見えますが、文字列のパターンマッチングにおいては非常 に強力な言語です。
# つまり、有効なメールアドレスだけにマッチして、
# 無効なメールアド レスにはマッチしない正規表現を組み立てる必要があります。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 3
# case_sensitive:大文字小文字の違いを確認する制約をかけるかどうか
# 一意性検証では大文字小文字を区別している為。
# 依然としてここには 1 つの問題が残っています。
# それは Active Record はデー タベースのレベルでは一意性を保証していないという問題です。
# “Submit” を素早く 2 回クリックして、メールアドレスを使ってユーザー登録した場合など。
# この問題はデータベースレベルでも一意性を強制するだけで解決します。
# 具体的にはデータベース上の email のカラムにインデックス(index)を追加し、
# そのイン デックスが一意であるようにすれば解決します。
# email インデックスを追加すると、データモデリングの変更が必要になります。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 4
# ユーザーをデータベースに保存する前にemail 属性を強制的に小文字に変換。メールアドレスが小文字で統一される。
# いくつかのデータベースのアダプタが、常に大文字小文字を区別するインデックス を使っているとは
# 限らない問題へ の対処です。例えば、Foo@ExAMPle.Com と foo@example.com が別々の文字列だ
# と解 釈してしまうデータベースがありますが、私達のアプリケーションではこれらの文字列 は同一で
# あると解釈されるべきです。今回は「データベース に保存される直前にすべての文字列を小文字に変換
# する」という対策を採ります。これを実装するために Active Record のコールバック(callback)
# メソッドを利用します。このメソッドは、ある特定の時点で呼び出されるメソッドです。今回の場合は、
# オブジェクトが保存される時点で処理を実行したいので、before_saveというコールバックを使います。
# これを使って、ユーザーをデータベースに保存する前にemail 属性を強制的に小文字に変換します。
# メールアドレスが小文字で統一される。
# self.email = self.email.downcase
# ↑ User モデルの中では右式の self を省略できる

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 5
# @セキュアパスワードという 手法では、各ユーザーにパスワードとパスワードの確認を入力させ、
# それを(そのままで はなく)ハッシュ化（データを元に戻せない不可逆なデータにする処理）したものを、
# データベースに保存します。
# ユーザーの認証は、パスワードの送信、ハッシュ化、データベース内のハッシュ化された値との比較、
# という手順で進んでいきます。比較の結果が一致すれば、送信されたパス ワードは正しいと認識され、
# そのユーザーは認証されます。
# ここで、生のパスワードではなく、ハッシュ化されたパスワード同士を比較していることに注目してください。
# これで、仮にデータベースの内容が盗まれたり覗き見されるようなことがあっても、
# パスワードの安全性が保たれます。

# @has_secure_password機能
# • セキュアにハッシュ化したパスワードを、データベース内の password_digest という属性に保存できるようになる。
# • 2つのペアの仮想的な属性(password と password_confirmation)が使えるようになる。
# また、存在性と値が一致するかどうかのバリデーションも追加される。
# ※仮想的：User モデルのオブジェクトからは存在しているように見えるが、
# データベースには対応するカラムが存在しない。
# • authenticate メソッドが使えるようになる(引数の文字列がパスワードと一致するとUserオブジェクトを返し、
#   間違っていると false を返すメソッド)。
# この魔術的な has_secure_password 機能を使えるようにするには、1 つだけ条件が あります。
# それは、モデル内に password_digest という属性が含まれていることです。
# has_secure_passwordを追加したばかりだと、テストが失敗する。
# 失敗する理由は、has_secure_passwordには、仮想的なpassword属性とpassword_confirmation属性に対して、
# バリデーションをする機能も (強制的に)追加されているからです。
# テストをパスさせるために、パスワードとパスワード確認の値を追加します。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 6
# このメソッドではユーザーオブジェクトが不要なので、このメソッドもUserモデルのクラスメソッドとして作成
# 一般に、あるメソッドがオブジェクトのインスタンスを必要としていない場合は、クラスメソッドにする のが常道です。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 7
# 記憶トークン(remember_token)をユーザーと関連付け、トークンに対応する記憶ダイジェストをデータベースに保存します。
# マイグレーションは実行済みなので、User モデルには既に remember_digest 属性が追加されていますが、
# remember_token 属性 はまだ追加されていません。このため user.remember_token メソッドを使って
# トークンにアクセスできるようにし、かつ、トークンをデータベースに保存せずに実装する必要があります。
# そこで、6.3 で行ったパスワードの実装と同様の手法でこれを解決します。あのときは仮想のpassword属
# 性と、データベース上にあるセキュアなpassword_digest 属性の 2 つを使いました。仮想の自動で作成された
# password属性は has_secure_password メソッドで 自動的に作成されましたが、今回は
# remember_token属性のコードを自分で書く必要があります。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 8
# attr_accessor:メソッド（セッター、ゲッター）を作るメソッド(メタプログラミング)。
# 引数で渡された属性を生成。
# 生成された属性に=（メソッド）を付けられる。
# セッター：a.remember_token=('foobar') みたいな。
# a.remember_token 'foobar'と同じ意味。
# ゲッター：a.remember_token *=>foobar みたいな。
# だからこれができるようになる→self.remember_token = User.new_token

# 仮想の password 属性は has_secure_password メソッドで自動的に作成されましたが、
# 今回は remember_token のコードを自分で書く必要があり ます。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 9
# update メソッドは属性のハッシュを受け取り、成功時には更新と保存を続けて同時に行います(保存に成功
# した場合は true を返します)。ただし、検証に 1 つでも失敗すると、 update の呼び出しは失敗し
# ます。例えば 6.3 で実装すると、パスワードの保存を要求するようになり、検証で失敗するようにな
# ります。特定の属性のみを更新したい場合は、次 のように update_attribute を使います。この
# update_attribute には、検証を回避 するといった効果もあります。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 10
# ブラウザの cookies を削除 する手段が未実装なので(20 年待てば消えますが)、ユーザーがログアウト
# できません。ユーザーがログアウトできるようにするために、ユーザーを記憶するためのメソッド と同様
# の方法で、ユーザーを忘れるためのメソッドを定義します。この user.forget メ ソッドによって、
# user.remember が取り消されます。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 11
# 新規ユーザー登録時に空のパスワードが有効になってしま うのかと心配になるかもしれませんが、安心してく
# ださい。6.3.3 で説明したように、 has_secure_password では(追加したバリデーションとは別に)オブ
# ジェクト生成時 に存在性を検証するようになっているため、空のパスワード(nil)が新規ユーザー登 録時に
# 有効になることはありません。(空のパスワードを入力すると存在性のバリデーションと has_secure_password
# によるバリデーションがそれぞれ実行され、2 つの同 じエラーメッセージが表示されるというバグがありま
# したが(7.3.3)、これで解決できました。)

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 12
# @ユーザーが新しい登録を完了するためには必ずアカウントの有効化が必要になるのですから、有効化トークンや有効化
# ダイジェストはユーザーオブジェクトが作成される前に作 成しておく必要があります。
# オブジェクトに before_save コールバックを用意しておくと、 オブジェクトが保存される直前、オブジェクトの作成時
# や更新時にそのコールバックが呼 び出されます。しかし今回は、オブジェクトが作成されたときだけコールバックを呼び出
# したいのです。それ以外のときには呼び出したくないのです。そこで before_create コールバックが必要になります。

# @このコードはメソッド参照と呼ばれるもので、こうすると Rails は create_activation_ digest というメソッドを探し、
# ユーザーを作成する前に実行するようになります(リ スト 6.32 では、before_save に明示的にブロックを渡していましたが、
# メソッド参照 の方がオススメできます)。create_activation_digest メソッド自体は User モデル 内でしか使わない
# ので、外部に公開する必要はありません。7.3.2 のときと同じように private キーワードを指定して、このメソッドを 
# Ruby 流に隠蔽します。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 13
# update_attributeは特に更新しないのでなし。
# 記憶トー クンやダイジェストは既にデータベースにいるユーザーのために作成されるのに対し、 activation_tokenの
# before_create コールバックの方はユーザーが作成される前に呼び出されることです。 このコールバックがあることで、
# User.new で新しいユーザーが定義されると(リス ト 7.19)、activation_token 属性や activation_digest 属性
# が得られるようになり ます。後者の activation_digest 属性は既にデータベースのカラムとの関連付けがで きあがっ
# ている(図 11.1)ので、ユーザーが保存されるときに一緒に保存されます。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 14
# 以前のコード
# *   *   *
# 渡された記憶トークン(remember_token)が記憶ダイジェスト(remember_digest)と一致したらtrue を返す
# def authenticated?(remember_token)
#   # ２番めのバグの問題
#   # 記憶ダイジェストがnilの場合にはreturnキーワードで即座にメソッドを終了。
#   # 処理を中途で終了する場合によく使われるテクニック。
#   return false if remember_digest.nil?
#   # bcryptを使ってcookies[:remember_token]がremember_digestと一致することを確認
#   BCrypt::Password.new(remember_digest).is_password?(remember_token)
# end
# *   *   *
# authenticated?メソッドの抽象化
# *「メタプログラミング」:「プログラムでプログラムを作成する」ことです。メタプログラミング は Ruby が有するきわ
# めて強力な機能。
# *send メソッド:渡されたオ ブジェクトに「メッセージを送る」ことによって、呼び出すメソッドを動的に決めることがで
# きます。
# *その他詳細はrails tutorialの11.3へ

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 15
# has_many:メソッドを作るメソッド
# サイト管理者はユーザーを破棄する権限を 持ちます。ユーザーが破棄された場合、ユーザーのマイクロポストも同様に破棄さ
# れるべきです。この振る舞いは、has_many メソッドにオプションを渡してあげることで実装できます(リスト 13.19)。
# dependent: :destroy というオプションを使うと、ユーザーが削除されたときに、そ のユーザーに紐付いた(そのユ
# ーザーが投稿した)マイクロポストも一緒に削除されるよ うになります。これは、管理者がシステムからユーザーを
# 削除したとき、持ち主の存在しないマイクロポストがデータベースに取り残されてしまう問題を防ぎます。

# 引数の:microposts シンボルから、Rails はこれに対応する Micropost モデルを探す。技術的には、Rails は
# has_many に渡された引数を classify メソッドを使ってクラス名に変換しています。
# 例えば、このメソッドに"foo_bars"を渡すと"FooBar"に変換されます。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 16
# @すべてのユーザーがフィードを持つので、feed メソッドは User モデルで作るのが自然です。
# フィードの原型では、まずは現在ログインしているユーザーのマイクロポストをすべて取得してきます。

# @このwhereはsqlのwherenのようなもの。
# whereメソッドとは、テーブル内の条件に一致したレコードを配列の形で取得することができるメソッドです。
# モデル名.where("条件")

# @?はプレースホルダーと呼ばれ、第二引数で指定した値が置き換えられます。
# モデル名.where("name = ?", "pikawaka")
# *↑上のコードは下記のコードと同じ
# モデル名.where("name = 'pikawaka'")
# モデル名.where(name: "pikawaka")

# @疑問符があることで、SQL クエリに代入する前に id がエスケープされるため、SQL インジェクション(SQL Injection)
# 呼ばれる深刻なセキュリティホールを避けることがで きます。この場合の id 属性は単なる整数(すなわち self.id は
# ユーザーの id)である ため危険はありませんが、SQL 文に変数を代入する場合は常にエスケープする習慣をぜ ひ身
# につけてください。
# ＊SQLインジェクションとは、SQLを呼び出す際にセキュリティ上の不備を利用して、データベースのデータを不正に操作す
# る攻撃方法のことを言います。

# @sql
# SELECT "フィールド(カラム)名"(全て取得)
# FROM "テーブル名"
# WHERE "フィールド名" IN ('値一', '値二', ...);
# ↓
# SELECT * FROM microposts
# WHERE user_id IN (<list of ids>) OR user_id = <user id>
# (<list of ids>):フォローしている他ユーザーのID

# @14章より
# ここで必要なのは、microposts テーブルから、あるユーザー(つまり自分自身)がフォローして いるユーザーに対応する id を持つマイクロポストをすべて選択(select)することです。 このクエリを模式的に書くと次のようになります。
# [SELECT * FROM microposts]
# [WHERE user_id IN (<list of ids>) OR user_id = <user id>]
# 上のコードを書く際に、SQL が IN というキーワードをサポートしていることを前提にし ています(大丈夫、実際にサ
# ポートされています)。このキーワードを使うことで、id の 集合の内包(set inclusion)に対してテストを行えます。
# 上のような選択を行うために Active Record の where メ ソッドを使っていることを思い出してください(リスト
# 13.46)。今回必要になる選択は、上よりも少し複雑で、例えば次のような形になります。
# [Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)]
# これらの条件から、フォローされているユーザーに対応する id の配列が必要であること がわかってきました。これを
# 行う方法の 1 つは、Ruby の map メソッドを使うことです。 このメソッドはすべての「列挙可能(enumerable)」な
# オブジェクト(配列やハッシュな ど、要素の集合で構成されるあらゆるオブジェクト)で使えます。
# 列挙可能(enumerable)オブジェクトであることの主な条件は、each メソッドを実装していることです。このメソッド
# はコレクションを列挙します。
# よく使われる方法であり、次のようにアンパサンド(Ampersand)& と、メソッドに対応 するシンボルを使った短縮
# 表記(4.3.2)が使えます。この短縮表記であれば、変数 i を使 わずに済みます。
# [ [1, 2, 3, 4].map(&:to_s)
# => ["1", "2", "3", "4"]]
# この結果に対して join メソッド(4.3.1)を使うと、id の集合をカンマ区切りの文字列と して繋げることができます。
# user.following にある各要素の id を呼び出し、フォローして いるユーザーの id を配列として扱うことができま
# す。例えばデータベースの最初のユー ザーに対して実行すると、次のような結果になります。
# [User.first.following.map(&:id)
#   => [3, 4, 5, 6, 7, 8, 9, 10]]
# 実際、この手法は実に便利なので、Active Record ではfollowing_idsメソッドも用意されています
# この following_ids メソッドは、has_many :following の関連付けをしたときに Active Record が自動生成し
# たものです(リスト 14.8)。これにより、user.following コレクションに対応する id を得るためには、関連付けの
# 名前の末尾に_ids を付け足すだ けで済みます。
# 結果として、フォローしているユーザー id の文字列は、次のようにして取 得することができます。
# [User.first.following_ids.join(', ')
# => "3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13"]
# なお、以上は説明のためのコードであり、実際に SQL 文字列に挿入するときは、この ように記述する必要はありません。実は、?を内挿すると自動的にこの辺りの面倒を見て くれます。さらに、データベースに依存する一部の非互換性まで解消してくれます。つま り、ここでは following_ids メソッドをそのまま使えばよいだけなのです。結果、最初 に想像していたとおり、
# [Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)]
# *?には後続の引数が入る。idはself.idの省略

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 17
# まずは 1 つ目の違いについてです。以前、ユーザーとマイクロポストの関連付けをした ときは、次のように書きました。
# [has_many :microposts]
# 引数の:microposts シンボルから、Rails はこれに対応する Micropost モデルを探し出 し、見つけることができました。
# ＊（技術的には、Rails は has_many に渡された引数を classify メソッドを使ってクラス名に変換しています。
# 例えば、このメソッドに"foo_bars"を渡すと"FooBar"に変換されます）
# しかし今回のケースで同じように書くと、
# [has_many :active_relationships]
# となってしまい、(ActiveRelationship モデルを探してしまい)Relationship モデルを見つ けることができません。
# このため、今回のケースでは、Rails に探して欲しいモデルのク ラス名を明示的に伝える必要があります。
# 2 つ目の違いは、先ほどの逆のケースについてです。以前は Micropost モデルで、
# [belongs_to :user]
# このように書きました。microposts テーブルには user_id 属性があるので、これを辿って対応する所有者(ユーザー)
# を特定することができました(13.1.1)。データベースの 2 つのテーブルを繋ぐとき、このような id は外部キー(foreign key)
# と呼びます。すなわち、User モデルに繋げる外部キーが、Micropost モデルの user_id 属性ということです。
# この外部キーの名前を使って、Rails は関連付けの推測をしています。
# *(技術的には、Rails は underscore メソッドを使ってクラス名を id に変換しています。例えば、 
#   "FooBar".underscore を実行すると"foo_bar"に変換されます。したがって、 FooBar オブジェクトの
#   外部キーは foo_bar_id になるでしょう)
# 具体的には、 Rails はデフォルトでは外部キーの名前を<class>_id といったパターンとして理解し、 <class>に
# 当たる部分からクラス名(正確には小文字に変換されたクラス名)を推測しま す*5 。ただし、先ほどはユーザーを例
# として扱いましたが、今回のケースではフォローしているユーザーを follower_id という外部キーを使って特定
# しなくてはなりません。また、follower というクラス名は存在しないので、ここでも Rails に正しいクラス名を
# 伝える必要が発生します。
# 先ほどの説明をコードにまとめると、User と Relationship の関連付けはこのようになります。

# active_relationship.follower                                   フォロワーを返します
# active_relationship.followed                                   フォローしているユーザーを返します
# user.active_relationships.create(followed_id: other_user.id)   userと紐付けて能動的関係を作成/登録する
# user.active_relationships.create!(followed_id: other_user.id)  userを紐付けて能動的関係を作成/登録する(失敗時にエラーを出力)
# user.active_relationships.build(followed_id: other_user.id)    userと紐付けた新しいRelationshipオブジェクトを返す

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 18
# followingメソッドを生成。active_relationshipsとfollowedメソッドを実行した結果を返す
# @user.active_relationships.map(&:followed)でも配列は取れるけど便利になるので。
# ちなみに
# @user.active_relationships.map(&:follower)だと@userがたくさん返ってくる

# through: :中間テーブル名
# [through: :active_relationships]なので、合わせて[has_many :active_relationships]を設定
# 多対多の関連を定義するには、モデルクラスにhas_manyメソッドのthroughオプションを使います。throughは、
# 「経由する」という意味なので中間テーブルを経由して関連先のオブジェクトを取得することが出来ます。
# 1つのUserオブジェクトはRelationshipモデルを経由して複数のfollowingオブジェクトを持っている」という意味

# デフォルトのhas_many throughという関連付けでは、Rails はモデル名(単数形)に対応する外部キーを探します。
# つまり、次のコードでは、
# (has_many :followeds, through: :active_relationships)
# Rails は「followeds」というシンボル名を見て、これを「followed」という単数形に変え、 relationships
# テーブルの followed_id を使って対象のユーザーを取得してきます。 しかし、14.1.1 で指摘したように、
# user.followeds という名前は英語として不適切で す。代わりに、user.following という名前を使いましょう。
# そのためには、Rails のデ フォルトを上書きする必要があります。ここでは:source パラメーター(リスト 14.8)
# を使って、「following 配列の元は followed id の集合である」ということを明示的に Rails に伝えます。

# 関連付けにより、フォローしているユーザーを配列の様に扱えるようになりました。例えば、include?メソッド(4.3.1)
# を使ってフォローしている ユーザーの集合を調べてみたり、関連付けを通してオブジェクトを探しだせるようになります。
# [user.following.include?(other_user)]
# [user.following.find(other_user)]

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 19
# 一点、リスト 14.12 で注意すべき箇所は、次のように参照先(followers)を指定する ための:source キーを省略し
# てもよかったという点です。
# (has_many :followers, through: :passive_relationships)
# これは:followers 属性の場合、Rails が「followers」を単数形にして自動的に外部キーfollower_id を探して
# くれるからです。リスト 14.12 と違って必要のない:source キー をそのまま残しているのは、
# has_many :followingとの類似性を強調させるためです。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 20
# ↓following_idsで一回、合計で2回問い合わせをしている
# Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
                    # following_ids: following_ids, user_id: id)

# サブセレクト(SQLの手法,SELECT文の中にSELECT文を入れる)で一つのクエリにまとめる

# 前者の疑問符を使った文法も便利ですが、同じ変数を複数の場所に挿入したい場合は、後者の置き換え後の文法を使う
# 方がより便利です。これから SQL クエリにもう 1 つの user_id を追加しま す。特に、次のRuby コードは、
# [following_ids]
# このような SQL に置き換えることができます。
# [following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"]
# このコードを SQL のサブセレクトとして使います。つまり、「ユーザー 1 がフォローして いるユーザーすべてを選択
# する」という SQL を既存の SQL に内包させる形になり、結果 として SQL は次のようになります。
# SELECT * FROM microposts
# WHERE user_id IN (SELECT followed_id FROM relationships
#                   WHERE follower_id = 1) 
#       OR user_id = 1
# このサブセレクトは集合のロジックを(Rails ではなく)データベース内に保存するので、 より効率的にデータ
# を取得することができます。
# もちろん、サブセレクトを使えばいくらでもスケールできるなどということはありませ ん。大規模な Web サービス
# では、バックグラウンド処理を使ってフィードを非同期で生 成するなどのさらなる改善が必要でしょう。ただし、
# Web サービスをスケールさせる技術 は非常に高度かつデリケートな問題なので、本書ではここまでの改善で止めてお
# きます。
# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
