Rails.application.routes.draw do
  resources :homes
  devise_for :users
  resources :posts
  

  root to: "home#index"


  
end
