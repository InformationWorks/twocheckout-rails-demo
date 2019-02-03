Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'home#index'
  get '/home', to: 'home#index'
  get "/inline-checkout", to: "home#inline_checkout", as: :inline_checkout
  get "/standard-checkout", to: "home#standard_checkout", as: :standard_checkout
  get "/2checkout/order-processed", to: "home#order_processed", as: :order_processed

end
