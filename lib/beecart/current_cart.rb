module Beecart
  module CurrentCart
    def current_cart
      if session[:cart_id]
        cart = Beecart::ShoppingCart.new(session[:cart_id])
      else
        session[:cart_id] 
        cart = Beecart::ShoppingCart.new()
        session[:cart_id] = cart.key
      end

      cart
    end
  end
end
