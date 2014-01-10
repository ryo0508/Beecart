Rails.application.routes.draw do
  # mount Beecart::Engine => "/beecart"

  root :to => 'carts#index'

  post    '/cart/checkout',    as: 'checkout_cart',    to: 'carts#charge'
  post    '/cart/add_item',    as: 'add_item',    to: 'carts#add_item'
  delete  '/cart/remove_item', as: 'remove_item', to: 'carts#remove_item'
  delete  '/cart', as: 'destroy_cart', to: 'carts#destroy'
end
