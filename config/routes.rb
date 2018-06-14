Rails.application.routes.draw do
  devise_scope :user do
    get 'signup', to: 'users/registrations#new', as: :registration
    post 'signup', to: 'users/registrations#create'
  end

  devise_for :users
  get 'pages/home'
  root 'pages#home'
end
