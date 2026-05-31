Rails.application.routes.draw do
  root 'todo_lists#index'

  namespace :api do
    resources :todo_lists, only: %i[index show create update destroy], path: :todolists do
      post :complete_all, to: 'todo_lists/complete_all#create'
      resources :todo_items, only: %i[index create update destroy]
    end
  end

  resources :todo_lists, only: %i[index create edit update destroy], path: :todolists do
    resource :name, only: %i[edit update], controller: 'todo_lists/name'

    post :complete_all, to: 'todo_lists/complete_all#create'
    resources :todo_items, only: %i[index create update destroy]
  end
end
