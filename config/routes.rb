Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  resources :business_ideas, only: [:new, :create, :index, :show, :destroy] do
    resources :business_datas, only: [:create]
    member do
        get :report
    end
  end

  resources :chats, only: [:show ] do
    resources :messages, only: [:create]
  end

  get "up" => "rails/health#show", as: :rails_health_check

end
