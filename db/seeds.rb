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
  admin: true)

# 追加のその他のユーザーをまとめて生成する
99.times do |n|
# 適当な名前を作る
name  = Faker::Name.name
email = "example-#{n+1}@railstutorial.org"
password = "password"
User.create!(name:  name,
    email: email,
    password:              password,
    password_confirmation: password)
end

# 1
# seedsファイル：コンソールに打ち込むがごとく、上からコードが実施される。
# この一つ一つのrubyスクリプトの事をタスク、またはrakeタスクと呼ぶ。
# create!は基本的に create メソッドと同じものですが、ユーザーが無効な場合に false を返すのではなく例外を発生
# させる(6.1.4)点が異なります。こうしておくと見過ごしや すいエラーを回避できるので、デバッグが容易になります。
# 何故なら例外が発生しないと、(nilを返して？)途中で止まらずエラー文が99回出るから。