module Cartbee
  class ApplicationController < ActionController::Base
    def current_cart
      if session[:cart_id]
        cart = ShoppingCart::ShoppingCart.new(session[:cart_id])
      else
        cart = ShoppingCart::ShoppingCart.new()
        session[:cart_id] = sc.key
      end

      cart
    end
  end
end
