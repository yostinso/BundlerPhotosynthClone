Dwp::Application.routes.draw do
  match "picture/destroy/:id" => "picture#destroy", :as => "picture_destroy"
  match "picture/destroy/" => "picture#destroy", :as => "picture_destroy_template"

  get "photoset/new"
  post "photoset/create"
  get "photoset/destroy"
  get "photoset/manage/:id" => "photoset#manage", :as => "manage_photoset"
  post "photoset/handle_upload/:id" => "photoset#handle_upload", :as => "photoset_handle_upload"
  match "photoset/bundle/:id" => "photoset#bundle", :as => "photoset_bundle"
  get "photoset/rebundle/:id" => "photoset#rebundle", :as => "photoset_rebundle"
  get "bundle/view/:id" => "bundle#view", :as => "bundle"
  get "bundle/ply_as_asc/:id/:bundler_file_id" => "bundle#ply_as_asc", :as => "ply_as_asc"
  get "bundle/ply/:id/:bundler_file_id" => "bundle#ply", :as => "ply"

  get "user/index"

  get "user_sessions/new", :as => "new_user_session"
  get "user_sessions/create"
  post "user_sessions/create", :as => "user_session"
  get "user/index", :as => "user_home"
  get "user_sessions/destroy", :as => "destroy_user_session"

  get "welcome/index", :as => "welcome"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
