Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get 'about', to: 'pages#about'
  get 'howitworks', to: 'pages#howitworks', as: :howitworks
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'show', to: 'pages#show'

end
