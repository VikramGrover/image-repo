Rails.application.routes.draw do
  get 'repository/index'

  root 'repository#index'
end
