Rails.application.routes.draw do
  
  
  resources :notifications
  resources :replies
  resources :nodes
  resources :homes

  resources :lists do
	resources :comments, only: [:index, :new, :create]
  end
  resources :comments, only: [:show, :edit, :update, :destroy]

  devise_for :users
  
  resources :posts
  

  root to: "homes#index"


  
end
