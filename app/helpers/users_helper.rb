# 1
module UsersHelper

  # 引数で与えられたユーザーの Gravatar 画像を返す def gravatar_for(user)
  # 2
  # ↓の別記法:def  gravatar_for(user, options = { size: 80 })
  def gravatar_for(user)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end


# 1
# module ApplicationHelperという要素について解説します。
# モジュールは、関連したメソッドをまとめる方法の1つで、include メソッドを使って
# モジュールを読み込むことができます(ミックスイン(mixed in)とも呼びます)。
# 単なる Ruby のコードを書くのであれば、モジュールを作成するたびに明示的に読み込んで使うのが普通ですが、
# Rails では自動的にヘルパーモジュールを読み込んでくれるので、 include 行をわざわざ書く必要がありません。
# 特定のコントローラだけが使うヘルパーであれば、それに対応するヘルパーファイルを置くとよいです。
# 例えばUserコントローラ用ヘルパーは、通常app/helpers/user_helper.rbになります。

# -   -   -   -   -   -   -   -  -   -   -   -   -   -   -   -   -   -   -   -
# 2
# @Gravatar の URL はユーザーのメールアドレスを MD5 と いう仕組みでハッシュ化しています。
# Ruby では、Digest ライブラリの hexdigest メソッドを使うと、MD5 のハッシュ化が実現できます。
# メールアドレスは大文字と小文字を区別しませんが、MD5 ハッシュでは大文字と 小文字が区別されるので、
# Ruby の downcase メソッドを使って hexdigest の引数を小文字に変換しています。
# (本チュートリアルでは、リスト6.32のコールバック処理で小文字変換されたメールアドレスを利用している
# ため、ここで小文字変換を入れなくても結果は同じです。ただし、将来 gravatar_for メソッドが別の
# 場所から呼びだされる可能性 を考えると、ここで小文字変換を入れることには意義があります。)

# @ユーザーのメールアドレスを組み込んだ Gravatar 専用の画像パスを構成するだけで、対応する
# Gravatarの画像が自動的に表示される

# @Gravatar の画像タグに gravatar クラスとユーザー名の alt テキ ストを追加したものを返します
# (alt テキストを追加しておくと、視覚障害のあるユーザー がスクリーンリーダーを使うときにも
#   役に立ちます)。

# @image_tagメソッド:@Railsのヘルパーメソッドの1つ。画像を表示する。
# メソッドの引数には、必須の引数として画像ファイルを指定します。
# またオプションとしてalt属性や画像のサイズ、そしてマウスオーバーの時の画像を指定することができます。