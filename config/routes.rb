Rails.application.routes.draw do
  # 1
  root 'static_pages#home'
  # 2
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/signup', to: 'users#new'
end

# =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =   =
# 1
# root メソッドを使ってルート URL "/" をコントローラーのアクションに紐付け。
# それ以外にも、生のURLではなく、名前付きルートを使ってURLを参照することができるようになります。
# 例えばルート URL を定義 すると、root_path や root_url といったメソッドを通して、
# URL を参照することがで きます。ちなみに前者はルート URL 以下の文字列を、
# 後者は完全な URL の文字列を返し ます。
# root_path -> '/'
# root_url -> 'https://www.example.com/'
# なお、Rails チュートリアルでは一般的な規約に従い、基本的には_path 書式を使い、
# リダイレクトの場合のみ_url 書式を使うようにします。これは HTTP の標準としては、
# リダイレクトのときに完全な URL が要求されるためです。ただしほとんどのブラウザでは、
# どちらの方法でも動作します。

# /static_pages/home というURLに対するgetリクエストを、StaticPagesコントローラのhomeアクションと結びつけています。
# get 'static_pages/home'

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 2
# [get 'static_pages/help']から名前付きルートで定義.
# GETリクエストが /help に送信されたときに、
# StaticPages コントローラーの help アクションを呼び出してくれるようになります。
# また、ルート URL のときと同様に、help_path や help_url といった名前付きルートも使えるようになります。
# help_path -> '/help'
# help_url -> 'https://www.example.com/help'