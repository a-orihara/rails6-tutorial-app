class StaticPagesController < ApplicationController


  # 1
  def home
    # 1 行のときは後置 if 文、2 行以上のときは前置 if 文を使うのが Ruby の慣習です。
    if logged_in?
      # current_user メソッドはユーザーがログインしているときしか使えません。したがって、@micropost変数
      # もログインしているときのみ定義されるようになります。
      @micropost = current_user.microposts.build
      # 2
      # フィード機能を導入するため、ログインユーザーのフィード用にインスタンス変数@feed_items を追加
      # @feed_itemはmicropostインスタンスの集合
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end

# 1
# /static_pages/home という URL にアクセスすると、Rails は StaticPages コントロー ラを参照し、
# home アクションに記述されているコードを実行します。その後、そのアク ションに対応するビューを出力します。今回の場合、home アクションが空になっているので、/static_pages/home にアクセスしても、
# 単に対応するビューが出力されるだけです。home アクションは home.html.erb というビューに対応しています。

# 2
# current_user.feed:現在ログインしているユーザーのマイクロポストをすべて取得
# paginateメソッド:ページネーションリンクを画面に出力