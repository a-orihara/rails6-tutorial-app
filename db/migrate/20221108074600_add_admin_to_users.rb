class AddAdminToUsers < ActiveRecord::Migration[6.0]
  def change
    # 1
    add_column :users, :admin, :boolean, default: false
  end
end

# 1
# :booleanはtrueかfalseだが、何も入っていないとnilが入る。後の検証で面倒なので、デフォをfalseにして
# nilが入らないようにする。
# defaultはmigrationファイル生成時に書き込めないので、このように直接記載する
# default: false という引数を add_column に追 加しています。これは、デフォルトでは管理者になれないという
# ことを示すためです。(default: false 引数を与えない場合、 admin の値はデフォルトで nil になります が、
# これは false と同じ意味ですので、必ずしもこの引数を与える必要はありません。 ただし、このように明示的に
# 引数を与えておけば、コードの意図を Rails と開発者に明確 に示すことができます)。

# booleanだと、?メソッドとtoggleメソッドが自動で付く