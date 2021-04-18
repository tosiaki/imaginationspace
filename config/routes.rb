Rails.application.routes.draw do
  root 'pages#home'
  get 'old_home', to: 'pages#old_home'
  get 'about', to: 'pages#about'
  get 'support_this_site', to: 'pages#support'

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
  resources :users, only: [:show, :edit, :update] do
    member do
      get :change_icon, as: :change_icon
      patch :change_icon, to: 'users#update_icon'
      get :change_password, as: :change_password
      patch :change_password, to: 'users#update_password'
      get :profile
      post :subscribe, as: :subscribe_to
      delete :unsubscribe, as: :unsubscribe_from
      get :subscriptions
      get :subscribers
      get :bookmarks
      get :preferences
      patch :preferences, to: 'users#update_preferences'
      get 'old_show'
    end
    resources :articles, only: :index
  end

  resources :statuses, only: :create

  resources :articles, only: [:new, :show, :create, :edit, :update, :destroy, :index] do
    member do
      get 'page/:page_number', action: :show, as: :show_page
      get 'add_page', to: 'article_pages#new', as: :add_page
      get 'add_page/:page_number', to: 'article_pages#new', as: :add_page_at
      post 'add_page', to: 'article_pages#create'
      # patch 'merge_page/:page_number', to: 'article_pages#merge'
      delete 'remove_page/:page_number', to: 'article_pages#destroy', as: :remove_page

      resources :signal_boosts, only: [:new, :create]

      post 'bookmark', to: 'bookmarks#create'
      delete 'unbookmark', to: 'bookmarks#destroy'

      post 'sticky', to: 'sticky#create'
      delete 'sticky', to: 'sticky#destroy'

      post 'kudos', to: 'kudos#create'

      post 'reply', to: 'articles#create', defaults: { reply: true }
    end
  end

  get 'threads/:thread_id', to: 'articles#index', as: :thread
  
  resources :signal_boosts, only: [:edit, :update, :destroy]

  resources :article_tags, only: :index

  mount Shrine.presign_endpoint(:cache) => "/s3/params"

  resources :drawings, only: [:new, :create, :show, :index, :edit, :update, :destroy], parent: "Drawing" do
    resources :comments, only: :create
    resources :kudos, only: :create
  end
  get 'drawings/tags/:tags', to: 'drawings#index', as: :drawings_by_tags

  resources :comics, only: [:new, :create, :show, :index, :edit, :update, :destroy], parent: "Comic" do
    resources :comments, only: :create
    resources :kudos, only: :create
    member do
      get 'page/:page', action: :show, as: :show_page
      get 'all', action: :show_all, as: :show_all
      get 'edit/:page', to: 'comic_pages#edit', as: :edit_page
      patch 'edit/:page', to: 'comic_pages#update'
    end
  end

  get 'comics/tags/:tags', to: 'comics#index', as: :comics_by_tags

  resources :comments, only: [:create, :show, :edit, :update, :destroy], parent: "Comment" do
    resources :comments, only: :create
  end

  resources :works, only: :index
  get 'works/search', to: 'works#search', as: :works_search
  get 'works/new_search', to: 'works#parse_search', as: :parse_search

  resources :series, only: [:create, :show, :update, :destroy]

  get 'comics/:id/new_page', to: 'comic_pages#new', as: :new_comic_page
  get 'comics/:id/new_page/:page', to: 'comic_pages#new', as: :new_comic_page_at
  post 'comics/:id/new_page', to: 'comic_pages#create'
  delete 'comics/:id/delete_page/:page', to: 'comic_pages#destroy', as: :delete_comic_page

  get 'users/:id/drawings', to: 'users#drawings', as: :user_drawings
  get 'users/:id/drawings/tags/:tags', to: 'users#drawings', as: :user_drawings_by_tags
  get 'users/:id/comics', to: 'users#comics', as: :user_comics
  get 'users/:id/comics/tags/:tags', to: 'users#comics', as: :user_comics_by_tags
  get 'users/:id/scanlations', to: 'users#scanlations', as: :user_scanlations
  get 'users/:id/scanlations/tags/:tags', to: 'users#scanlations', as: :user_scanlations_by_tags

  post ':work/:id/bookmark', to: 'bookmarks#create', as: :bookmark
  delete ':work/:id/unbookmark', to: 'bookmarks#destroy', as: :unbookmark

  get 'users/:id/bookmarked_drawings', to: 'users#bookmarked_drawings', as: :user_bookmarked_drawings
  get 'users/:id/bookmarked_comics', to: 'users#bookmarked_comics', as: :user_bookmarked_comics

  get ':board', to: 'articles#index', as: :board

  mount ActionCable.server => '/cable'
end
