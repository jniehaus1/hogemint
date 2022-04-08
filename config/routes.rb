Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :items,      only: [:new, :create, :index, :show]
  resources :test_items, only: [:new, :create, :index, :show]

  if ENV["PRINTER_IS_LIVE"] == true
    root to: 'items#new'
  else
    root to: 'test_items#new'
  end
end
