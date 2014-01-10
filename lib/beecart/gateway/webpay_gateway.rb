# -*- coding: utf-8 -*-

module Beecart
  module Gateway
    class WebpayGateway < Beecart::Gateway::BaseGateway
      # @param [Hash] payment_info 支払い方法に関してのハッシュ
      def initialize *args
        super

        # raise Error, "You need to set Webpay API Key" if Webpay.api_key.nil?
      end

      def charge price, payment_info

        charge_info = {
          amount: price,
          currency: "jpy",
          capture: true
        }.merge(payment_parser(payment_info))

        Rails.logger.debug "charge_info => #{ charge_info }"

        WebPay::Charge.create(charge_info)
      end

      def authorize price, payment_info
        charge_info = {
          amount: price,
          currency: "jpy",
          capture: false
        }.merge(payment_parser(payment_info))

        WebPay::Charge.create(charge_info)
      end

      private

      def payment_parser info

        Beecart.logger.debug "info => #{ info }"

        if info.has_key? :customer
          return  {
            customer: info[:customer]
          }
        else
          return {
            card: {
              number:     info[:card][:number],
              exp_month:  info[:card][:exp_month],
              exp_year:   info[:card][:exp_year],
              cvc:        info[:card][:cvc],
              name:       info[:card][:name],
            }
          }
        end
      end
    end
  end
end
