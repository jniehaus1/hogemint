Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'items#new'
  get "failed", to: 'items#failed'

  resources :items
  resources :tokens
end
