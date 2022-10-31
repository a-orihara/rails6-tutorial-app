Rails.application.routes.draw do
  # 1
  root 'static_pages#home'
  # 2
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/signup', to: 'users#new'
  # 3
  resources :users
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

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 3
# @RESTアーキテクチャの習慣、つまり、データの作成、表示、更新、削除をリソース(Resources)として
# 扱うということです。HTTP 標準には、これらに対応 する4つの基本操作(POST、GET、PATCH、DELETE)
# が定義されているので、これら の基本操作を各アクションに割り当てていきます。

# @resources :users という行は、ユーザー情報を表示する URL(/users/1)を追加するためだけの
# ものではありません。サンプルアプリケーションにこの1行を追加すると、 ユーザーの URL を生成す
# るための多数の名前付きルートと共に、RESTful な Users リソースで必要となるすべてのアクション
# が利用できるようになるのです。この行に対応する生成されるURLやアクション、名前付きルートは下記のように
# なります。
# HTTP    URL            アクション  名前付きルート          用途
# GET     /users         index     users_path            すべてのユーザーを一覧するページ
# GET     /users/1       show      user_path(user)       特定のユーザーを表示するページ
# GET     /users/new     new       new_user_path         ユーザーを新規作成するページ(ユーザー登録)
# POST    /users         create    users_path            ユーザーを作成するアクション
# GET     /users/1/edit  edit      edit_user_path(user)  id=1のユーザーを編集するページ
# PATCH   /users/1       update    user_path(user)       ユーザーを更新するアクション
# DELETE  /users/1       destroy   user_path(user)       ユーザーを削除するアクション
# *Rails の REST 機能が有効になっていると、GET リクエストは自動的に show アクションとして扱われ ます。
# 今回はジェネレータを使っていないので、show.html.erb ファイルを手動で作成する必要があります。
# したがって、app/views/users/show.html.erb ファイルを手動で作成します。




