# 1
class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    # create_table:ユーザーを保存するためのテーブルをデータベースに作成する。
    create_table :users do |t|
      t.string :name
      t.string :email
      # timestampsはdatetime型
      t.timestamps
    end
  end
end

# 1
# マイグレーションファイル名の先頭には、それが生成された時間のタイムスタンプが追加されます。
# マイグレーション自体は、データベースに与える変更を定義した change メソッドの集まりです。
# changeメソッドは create_table というRailsのメソッドを呼び、
# ユーザーを保存するためのテーブルをデータベースに作成します。
# create_table メソッドはブロック変数(ここでは(“table”の頭文字を取って)t)を1つ持つブロックを受け取ります。
# そのブロックの中でcreate_tableメソッドはtオブジェクトを使って、
# nameとemailカラムをデータベースに作ります。
# t オブジェクトが具体的に何をしているのかを正確に知る必要はありませんので、
# どうか心配しないでく ださい。抽象化レイヤの素晴らしい点は、
# それが何であるかを知る必要がないという点です。安心して t オブジェクトに仕事を任せればよいのです。