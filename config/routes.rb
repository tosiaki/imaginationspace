Rails.application.routes.draw do
  devise_scope :user do
    get 'signup', to: 'users/registrations#new', as: :registration
    post 'signup', to: 'users/registrations#create'
    get 'login', to: 'users/sessions#new', as: :login
    get 'logout', to: 'users/sessions#destroy', as: :logout
  end

  devise_for :users
  get 'pages/home'
  root 'pages#home'
end
