# -*- coding: utf-8 -*-

module Beecart
  module Gateway
    class WebpayGateway < Beecart::Gateway::BaseGateway
      # @param [Hash] payment_info 支払い方法に関してのハッシュ
      def initialize *args
        super

        Webpay.api_key = "test_secret_2TLg1y5kU5dye9v2BO9pd8yy"
        # raise Error, "You need to set Webpay API Key" if Webpay.api_key.nil?
      end

      def charge price, payment_info

        charge_info = {
          amount: price,
          currency: "jpy",
          capture: true
        }.merge(payment_parser(payment_info))

        WebPay::Charge.create(charge_info)
      end

      def examine price, payment_info
        charge_info = {
          amount: price,
          currency: "jpy",
          capture: false
        }.merge(payment_parser(payment_info))

        WebPay::Charge.create(charge_info)
      end

      private

      def payment_parser info
        if info.has_key? :customer
          return  {
            customer: info[:customer]
          }
        else
          return {
            card: {
              number:     info[:number],
              exp_month:  info[:exp_month],
              exp_year:   info[:exp_year],
              cvc:        info[:cvc],
              name:       info[:name],
            }
          }
        end
      end
    end
  end
end
