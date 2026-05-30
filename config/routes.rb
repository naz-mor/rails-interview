Rails.application.routes.draw do
  root 'todo_lists#index'

  namespace :api do
    resources :todo_lists, only: %i[index show create update destroy], path: :todolists do
      resources :todo_items, only: %i[create update destroy]
    end
  end

  resources :todo_lists, only: %i[index new create edit update destroy], path: :todolists do
    resources :todo_items, only: %i[new create update destroy]
  end
end
