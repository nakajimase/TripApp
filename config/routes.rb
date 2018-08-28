Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

#match 'article' => to: 'article#hello', via: [:get, :post]
match 'article/hello', to: 'article#hello', via: :get
match 'article/getList', to: 'article#getList', via: :get
match 'article/getDetail/:article_id', to: 'article#getDetail', via: :get

match 'user/hello', to: 'user#hello', via: :get
#match 'user/add/:email/:password', to: 'user#userAdd', via: :get
#match 'user/add', to: 'user#userAdd', via: :get
match 'user/add', to: 'user#userAdd', via: :post

end
