Rails.application.routes.draw do
  get 'repository/index'
  root 'repository#index'

  resources :repository do
    get :search, on: :collection
    get :clear_search, on: :collection
    get :download, on: :collection
    delete :delete, on: :collection
    post :upload, on: :collection
    post :image_search, on: :collection
  end
end
