Rails.application.routes.draw do
  root :to => 'carts#index'

  post    '/cart/checkout',    as: 'checkout_cart',    to: 'carts#charge'
  post    '/cart/examine',     as: 'examine_cart',     to: 'carts#charge'
  post    '/cart/add_item',    as: 'add_item',    to: 'carts#add_item'
  post    '/cart/append_data', as: 'append_info_cart', to: 'carts#append_info'
  delete  '/cart',             as: 'destroy_cart', to: 'carts#destroy'
  delete  '/cart/remove_item', as: 'remove_item', to: 'carts#remove_item'
  put     '/cart/:item_key/edit', as: 'edit_item', to: 'carts#edit_item'
end
