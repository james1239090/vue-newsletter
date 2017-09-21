Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "newsletters#index"

  resources :newsletters do
    member do
       post :sendWithMailgun
       post :sendWithSendgrid
       post :sendEmail
    end
  end


end
