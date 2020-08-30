Rails.application.routes.draw do
  get 'repository/index'
  root 'repository#index'

  resources :repository do
    post :upload, on: :collection
  end
end
