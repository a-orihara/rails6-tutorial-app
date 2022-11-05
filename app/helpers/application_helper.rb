# 1
module ApplicationHelper

# 2
  # ページごとの完全なタイトルを返します。
  def full_title(page_title = '')
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

end

# 1
# module ApplicationHelperという要素について解説します。
# モジュールは、関連したメソッドをまとめる方法の1つで、include メソッドを使って
# モジュールを読み込むことができます(ミックスイン(mixed in)とも呼びます)。
# 単なる Ruby のコードを書くのであれば、モジュールを作成するたびに明示的に読み込んで使うのが普通ですが、
# Rails では自動的にヘルパーモジュールを読み込んでくれるので、 include 行をわざわざ書く必要がありません。
# つまり、この full_title メソッドは自動 的にすべてのビューで利用できるようになっている、ということです。

# 2
# 特定のコントローラだけが使うヘルパーであれば、それに対応するヘルパーファイルを置くとよいです。
# 例えばStaticPagesコントローラ用ヘルパーは、通常app/helpers/static_pages_helper.rbになります。
# 今回の場合、full_titleヘルパーはサイトのすべてのページで使うことを前提にしていますが、
# Railsにはこのような場合のための特別なヘルパーファイルapp/helpers/application_helper.rbがあります。