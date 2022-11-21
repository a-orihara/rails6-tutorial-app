# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# メインの管理者のサンプルユーザーを1人作成する
# 1
User.create!(name:  "Example User",
  email: "example@railstutorial.org",
  password:              "foobar",
  password_confirmation: "foobar",
  admin: true,
  activated: true,
  # Time.zone.now:Rails の組み込みヘルパーであり、サーバーのタイムゾーンに応じたタイムスタンプを返します。
  activated_at: Time.zone.now)

# 追加のその他のユーザーをまとめて生成する
99.times do |n|
# 適当な名前を作る
name  = Faker::Name.name
email = "example-#{n+1}@railstutorial.org"
password = "password"
User.create!(name:  name,
    email: email,
    password:              password,
    password_confirmation: password,
    activated: true,
    activated_at: Time.zone.now)
end

# ユーザーの一部を対象にマイクロポストを作成されたユーザーの最初の6人に生成する
users = User.order(:created_at).take(6)
50.times do
  # Faker::Lorem.sentence:loremipsumと呼ばれるダミーのテキストを返す
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |user| user.microposts.create!(content: content) }
end

# 以下のリレーションシップを作成する
users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
# 最初のユーザーにユーザー 3 からユーザー 51 までをフォローさせ
following.each { |followed| user.follow(followed) }
# ユーザー 4 からユーザー 41 に最初のユーザーをフォローさせます。
followers.each { |follower| follower.follow(user) }

# 1
# 基本的に開発環境で使うデータの作成を担うファイル。
# seedsファイル：コンソールに打ち込むがごとく、上からコードが実施される。
# この一つ一つのrubyスクリプトの事をタスク、またはrakeタスクと呼ぶ。
# create!は基本的に create メソッドと同じものですが、ユーザーが無効な場合に false を返すのではなく例外を発生
# させる(6.1.4)点が異なります。こうしておくと見過ごしや すいエラーを回避できるので、デバッグが容易になります。
# 何故なら例外が発生しないと、(nilを返して？)途中で止まらずエラー文が99回出るから。