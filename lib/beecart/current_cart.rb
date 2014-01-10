# -*- coding: utf-8 -*-

module Beecart

  # ApplicationControllerや任意のControllerの中でinclude
  module CurrentCart

    # セッションで保持しているキーをもとに自分が保持しているカートを返却
    #
    # @return [ShoppingCart]
    def current_cart
      if session[:cart_id]
        cart = Beecart::Cart.new(session[:cart_id])
      else
        session[:cart_id]
        cart = Beecart::Cart.new()
        session[:cart_id] = cart.key
      end

      cart
    end
  end
end
