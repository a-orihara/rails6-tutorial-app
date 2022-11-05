class StaticPagesController < ApplicationController


  # 1
  def home
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