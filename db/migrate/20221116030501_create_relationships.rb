class CreateRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    # 高速化のためのインデックス。よく使う項目は、高速化のため、:follower_id,:followed_idにそれぞれインデックス（カラム）追加
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # 1 一意性のためのインデックス
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end

# 1
# DBレベルでユニークなことを担保するため、付ける。railsでもバリデーションをかけるが、DBレベルで付ける
# つまり、同じユーザーが同じユーザーを何度も、複数回フォローできないようにする(複合キーインデックス)

# 複合キーインデックス:follower_idとfollowed_idの組み合わせが必ずユニークであることを保証する仕組み
# あるユーザーが同じユーザーを2回以上フォローすることを防ぎます
# もちろん、このような重複(2 回以上フォロー すること)が起きないよう、インターフェイス側の実装でも注意を払いま
# す(14.1.4)。し かし、ユーザーが何らかの方法で(例えば curl などのコマンドラインツールを使って)
# Relationship のデータを操作するようなことも起こり得ます。そのような場合でも、一意 なインデックスを追加し
# ていれば、エラーを発生させて重複を防ぐことができます。