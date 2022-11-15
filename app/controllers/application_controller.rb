class ApplicationController < ActionController::Base
  # 1
  include SessionsHelper

  # 2
  private
    # user、micropostコントローラーの双方で使用するメソッドなので、このファイルに定義
    # before アクション
    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
      # ログイン前にアクセスしようとしたURLをsessionのハッシュに[:forwarding_url]キーで保存して覚えておく
      store_location
      flash[:danger] = "Please log in."
      # to /login
      redirect_to login_url
      end
    end
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

# 2
# Java や C++ といった言語の挙動とは異なり、Ruby の Private メソッドは継承クラス(userやmicropostコント
# ローラー)からも呼び出すことができる点に注意
# Microposts コントローラからも logged_in_user メ ソッドを呼び出せるようになりました。これにより、create
# アクションや destroy ア クションに対するアクセス制限が、before フィルターで簡単に実装できるようになり
# ます
