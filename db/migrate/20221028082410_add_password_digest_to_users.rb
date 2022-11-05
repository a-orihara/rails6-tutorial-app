class AddPasswordDigestToUsers < ActiveRecord::Migration[6.0]
  def change
    # 1
    add_column :users, :password_digest, :string
  end
end

# 1
# add_column メソッドを使って users テーブル password_digest カラムを追加しています。
# これを適用させるには、データベースでマイグレーションを実行します。