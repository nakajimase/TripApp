Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
#match 'article' => to: 'article#hello', via: [:get, :post]
#match 'article' => 'article#hello'
#get   '/article', to: 'article#hello'
#match 'article/hello' => 'article#hello' :via => :get
match 'article/hello', to: 'article#hello', via: :get

end
