Rails.application.routes.draw do
  resources :comments
  resources :lists
  resources :homes
  devise_for :users
  resources :posts
  

  root to: "homes#index"


  
end
