# -*- coding: utf-8 -*-

module Beecart
  module Validators
    class BaseValidator

      include Beecart::Validator

      attr_reader :error, :messages

      def initialize
        @error       = false
        @target_data = nil
        @messages = []
      end

      # Run the validation for given data
      #
      # @param [Hash] data Data that should be validated
      # @return [Boolean] Result of Validation[:w
      def run args
        @target_data = args
        @error ? false : true
      end

      protected

      def record_error error_message
        @messages << error_message
        @error    = true
      end
    end
  end
end
