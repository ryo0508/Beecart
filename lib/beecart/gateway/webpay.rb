# -*- coding: utf-8 -*-

require 'webpay'

module Beecart
  module Gateway
    class Webpay < Beecart::Gateway::Base

      def initialize *args
        super

        raise Error, "You need to set Webpay API Key" if Webpay.api_key.nil?
        end
      end

      def charge price
        WebPay::Charge.create(
          amount: price,
          currency: "jpy",

          capture: false
        )
      end

      def examine price
        WebPay::Charge.create(
          amount: price,
          currency: "jpy",

          capture: false
        )
      end

    end
  end
end
