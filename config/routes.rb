Rails.application.routes.draw do
  get 'pages/home'
  root 'pages#home'

  devise_scope :user do
    get 'signup', to: 'users/registrations#new', as: :registration
    post 'signup', to: 'users/registrations#create'
    get 'login', to: 'users/sessions#new', as: :login
    # get 'login', to: 'users/sessions#new', as: :new_user_session
    post 'login', to: 'users/sessions#create'
    get 'logout', to: 'users/sessions#destroy', as: :logout
    get 'resend_confirmation', to: 'users/confirmations#new', as: :resend_confirmation
    post 'resend_confirmation', to: 'users/confirmations#create'
    get 'reset_password', to: 'users/passwords#new', as: :reset_password
    post 'reset_password', to: 'users/passwords#create'
  end

  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    passwords: "users/passwords"
  }
  resources :users, only: :show

  resources :drawings, only: [:new, :create, :show, :index, :edit, :update, :destroy]
  get 'drawings/tags/:tags', to: 'drawings#index', as: :drawings_by_tags

  resources :comics, only: [:new, :create, :show, :index, :edit, :update, :destroy]
  get 'comics/tags/:tags', to: 'comics#index', as: :comics_by_tags

  get 'comics/:id/new_page', to: 'comic_pages#new', as: :new_comic_page
  get 'comics/:id/new_page/:page', to: 'comic_pages#new', as: :new_comic_page_at
  post 'comics/:id/new_page', to: 'comic_pages#create'
  delete 'comics/:id/delete_page/:page', to: 'comic_pages#destroy', as: :delete_comic_page

  get 'users/:id/drawings', to: 'users#drawings', as: :user_drawings
  get 'users/:id/drawings/tags/:tags', to: 'users#drawings', as: :user_drawings_by_tags
  get 'users/:id/comics', to: 'users#comics', as: :user_comics
  get 'users/:id/comic/tags/:tags', to: 'users#comics', as: :user_comics_by_tags
end
