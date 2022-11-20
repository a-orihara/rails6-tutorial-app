# このファイルでルート（URL）、名前付きルートを生成する。
Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'sessions/new'
  # 1
  root 'static_pages#home'
  # 2
  get '/help', to: 'static_pages#help'
  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/signup', to: 'users#new'
  # 4
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  # 6
  # resourcesがブロック付き引数を受け取っている
  resources :users do
    member do
      get :following, :followers
    end
  end
  # 3
  resources :users
  # editのURL、アクション、対応する名前付きルートのみ作成(デフォは7つ)  
  # GET  /account_activation/トークン/edit  edit_account_activation_url(token)
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
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

# @resources:URL、7アクション、対応する名前付きルートを生成
# resources :users という行は、ユーザー情報を表示する URL(/users/1)を追加するためだけの
# ものではありません。サンプルアプリケーションにこの1行を追加すると、 ユーザーの URL を生成す
# るための多数の名前付きルートと共に、RESTful な Users リソースで必要となるすべての7アクション
# が利用できるようになるのです。この行に対応する生成されるURLや7アクション、名前付きルートは下記のように
# なります。
# HTTP    URL            アクション  名前付きルート          用途
# GET     /users         index     users_path            すべてのユーザーを一覧するページ
# GET     /users/1       show      user_path(user)       特定のユーザーを表示するページ
# GET     /users/new     new       new_user_path         ユーザーを新規作成するページ(ユーザー登録)
# POST    /users         create    users_path            ユーザーを作成するアクション
# GET     /users/1/edit  edit      edit_user_path(user)  id=1のユーザーを編集するページ
# PATCH   /users/1       update    user_path(user)       ユーザーを更新するアクション
# DELETE  /users/1       destroy   user_path(user)       ユーザーを削除するアクション

# GET   /password_resets/new          new     new_password_reset_path
# POST  /password_resets              create  password_resets_path
# GET   /password_resets/トークン/edit  edit    edit_password_reset_url(token)
# PATCH /password_resets/トークン       update  password_reset_url(token)

# POST   /microposts    create   microposts_path
# DELETE /microposts/1  destroy  micropost_path(micropost)

# POST    /relationships(.:format)      create   relationships_path
# DELETE  /relationships/:id(.:format)  destroy  relationship_path	

# *Rails の REST 機能が有効になっていると、GET リクエストは自動的に show アクションとして扱われ ます。
# 今回はジェネレータを使っていないので、show.html.erb ファイルを手動で作成する必要があります。
# したがって、app/views/users/show.html.erb ファイルを手動で作成します。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 4
# Usersリソースのときは専用のresourcesメソッドを使って RESTful なルーティングを自動的にフルセット
# で利用できるようにしましたが、Session リソースではフルセットはいらないので、「名前付きルーティン
# グ」だけを使います。この名前付きルーティングでは、GET リクエストや POST リクエストを loginルー
# ティングで、 DELETE リクエストを logout ルーティングで扱います。
# なお、rails generateでnewアクションを生成すると、それに対応するビューも生 成されます。create
# や destroy には対応するビューが必要ないので、無駄なビューを 作成しないためにここでは new だけ
# を指定しています。
# rails routesコマンドを実行してみま しょう。いつでも現状のルーティングを確認することができます。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 5
# 従来の Rails 開発の慣習と異なる箇所が 1 つあります。Microposts リソースへのイン ターフェイスは、主にプ
# ロフィールページと Home ページのコントローラを経由して 実行されるので、Microposts コントローラには new
# や edit のようなアクションは不要 ということになります。つまり、create と destroy があれば十分です。
# したがって、 Microposts のリソースはこのようになります。その結果、この（13.30のコード）は、RESTfulな
# ルーティングのサブセットになります。

# -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
# 6
# 7つのアクション以外のアクションを追加する場合はルーティングの中でmemberとcollectionを使用します。
# memberはidで指定した個々のリソースに対するアクションを定義できます。
# /users/ユーザーのid/指定した名前

# どちらもデータを表示するページなので、適切な HTTP メソッドは GET リクエストになります。したがって、get
# メソッドを使って適切なレスポンスを返 すようにします。ちなみに、member メソッドを使うとユーザー id が含
# まれている URL を扱うようになりますが、 id を指定せずにすべてのメンバーを表示するには、collectionメソッド
# を使います。

# ユーザー1のフォローユーザーの集合
# GET  /users/1/following  following  following_user_path(1)
# ユーザー1のフォロワーの集合
# GET  /users/1/followers  followers  followers_user_path(1)