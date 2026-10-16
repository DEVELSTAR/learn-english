Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root "home#index"

  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token
  resource :registration, only: %i[new create]

  resources :lessons, only: %i[index show] do
    member do
      post :toggle_completion
      post :toggle_revision
      delete :clear_chat
    end
    resources :chat_messages, only: %i[create], module: :lessons
  end

  resources :word_lists, only: %i[index show create destroy]
  resources :word_entries, only: %i[create update destroy] do
    member do
      post :toggle_revision
      patch :update_status
    end
  end

  get "revision", to: "revisions#index", as: :revision
  post "revision/:id/reviewed", to: "revisions#reviewed", as: :revision_reviewed



  get "up" => "rails/health#show", as: :rails_health_check
end
