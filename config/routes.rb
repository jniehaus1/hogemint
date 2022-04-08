Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :test_items, only: [:new, :create, :show]
  resources :items,      only: [:show]
  resources :base_items, only: [:new, :create, :show]

  get '/uri/:id', to: 'items#uri'

  get  '/new_session', to: 'base_items#new_session'
  post '/login',       to: 'base_items#login'

  get 'faq',      to: 'statics#faq'
  get 'guide',    to: 'statics#guide'

  post 'coingate/callback', to: 'coingates#callback'

  if ENV["PRINTER_IS_LIVE"] == 'true'
    root to: 'items#new'
    resources :items, only: [:new, :create]
  else
    root to: 'test_items#new'
  end
end
