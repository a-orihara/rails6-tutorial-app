Rails.application.routes.draw do
  root 'static_pages#home'
  # /static_pages/home というURLに対するgetリクエストを、StaticPagesコントローラのhomeアクションと結びつけています。
  get 'static_pages/home'
  get 'static_pages/help'
  get 'static_pages/about'
end
