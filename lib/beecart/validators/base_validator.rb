# -*- coding: utf-8 -*-

module Beecart
  module Validators
    class BaseValidator

      include Beecart::Validator

      attr_reader :valid, :target_data, :errors

      def initialize
        @valid       = true
        @target_data = nil
        @errors      = {
          messages: [],
          keys: []
        }
      end

      # Run the validation for given data
      #
      # @param [Hash] data Data that should be validated
      # @return [Boolean] Result of Validation[:w
      def run args
        @target_data = args
        @valid
      end

      protected

      def record_error error_message, keys=nil
        @errors[:messages] << error_message
        @errors[:keys]     << key
        @valid = false
      end
    end
  end
end
