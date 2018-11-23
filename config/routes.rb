Rails.application.routes.draw do
  resources :programs
  get 'about/index'


  resources :dances, except: [:index]
  post 'dances_filter', to: 'dances#index'
  resources :duts, only: [:create, :destroy]
  resources :choreographers
  devise_for :users, controllers: { registrations: "users/registrations" }
  resources :users, only: [:show, :index] do
    put :update_preferences
  end
  resources :figures, only: [:index, :show]
  resources :idioms, only: [:create, :update, :destroy]

  get 'welcome/index'

  resource :dialect, only: [] do
    get :index
    post :roles
    post :roles_restore_defaults
    post :gyre
    post :restore_defaults
  end

  get 'about' => 'about#index'
  get '/help' => 'help#index'
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
