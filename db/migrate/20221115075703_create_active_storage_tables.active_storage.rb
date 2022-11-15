# This migration comes from active_storage (originally 20170806125915)
# Active Storage:[rails active_storage:install]でこのファイルが作成される
class CreateActiveStorageTables < ActiveRecord::Migration[5.2]
  def change
    create_table :active_storage_blobs do |t|
      t.string   :key,        null: false
      t.string   :filename,   null: false
      t.string   :content_type
      t.text     :metadata
      t.bigint   :byte_size,  null: false
      t.string   :checksum,   null: false
      t.datetime :created_at, null: false

      t.index [ :key ], unique: true
    end

    create_table :active_storage_attachments do |t|
      t.string     :name,     null: false
      t.references :record,   null: false, polymorphic: true, index: false
      t.references :blob,     null: false

      t.datetime :created_at, null: false

      t.index [ :record_type, :record_id, :name, :blob_id ], name: "index_active_storage_attachments_uniqueness", unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end
  end
end

# 1
# Rails でファイルをアップロードするのに最も便利な方法は、Rails に組み込まれている Active Storage とい
# う機能を用いることです*17。Active Storage を使うことで画像を簡単 に扱うことができ、画像に関連付けるモ
# デルも自由に指定できます(Micropost モデルな ど)。ここでは Active Storage を画像アップロードにしか使
# いませんが、Active Storage は かなり一般性の高いつくりになっており、平文テキストはもちろん、PDF ファイ
# ルや音声ファイルといったさまざまなバイナリファイルも扱えます。Active Storage ガイドにも記載されているよ
# うに、Active Storage をアプリケーションに追加するのはとても簡単です。
# [rails active_storage:install]
# 上のコマンドを実行すると、添付ファイルの保存に用いるデータモデルを作成するための データベースマイグレーシ
# ョンが 1 つ生成されます。