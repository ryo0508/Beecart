# -*- coding: utf-8 -*-

module Beecart
  module Gateway
    class BaseGateway

      def initialize *args; end

      # クレジットカードで本決済をかける
      #
      # @param [Integer] price 決済手段にて支払う額
      # @return [Boolean]
      def charge price; end

      # クレジットカードに対して与信をかける
      #
      # @param [Integer] price 与信をかける額
      # @return [Boolean]
      def examine price; end

    end
  end
end
