class ApplicationController < ActionController::Base
  # 1
  include SessionsHelper
end

# 1
# Railsのhelperは、ViewをDRYに作ることができるように配慮されたモジュール。
# もちろん、モジュールですので、モデルやコントローラでも利用できます。
# ・helperを使うことで、DRYに則したプログラムを書くことができる
# ・Viewであれば、helperをすぐに使用できる
# ・モデルとコントローラでhelperを使う場合は、モジュールをincludeしなければいけない
# ・「app/helpers」ディレクトリにファイル追加するなどして、helperを追加することができる
# ・ファイル名は「xxxx_helper.rb」でモジュール名は「XxxxHelper」
# ・ヘルパー名に同じものがあった場合、実行されるヘルパーは不定
# ・helperを作るのは、DRYに即することになるかどうかを基準にする