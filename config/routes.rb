Rails.application.routes.draw do
  devise_for :users

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # pages
  root to: 'pages#home'

  # website

  resources :websites, only: :create

  #version

  resources :versions, only: :show

  # dashboard

  resources :users, only: :show
end
