Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'home#index'
  get '/home', to: 'home#index'
  get "/inline-checkout", to: "home#inline_checkout", as: :inline_checkout
  get "/standard-checkout", to: "home#standard_checkout", as: :standard_checkout
  get "/2checkout/order-processed", to: "home#order_processed", as: :order_processed

  # Convert Plus
  get "/covert-plus/checkout", to: "twocheckout#checkout", as: :convert_plus_checkout
  post "/covert-plus/proceed-to-pay", to: "twocheckout#proceed_to_pay", as: :convert_plus_proceed_to_pay
  get "/covert-plus/order-processed", to: "twocheckout#order_processed", as: :convert_plus_order_processed

end
