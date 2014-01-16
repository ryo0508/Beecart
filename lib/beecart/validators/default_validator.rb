# -*- coding: utf-8 -*-

module Beecart
  module Validators
    class DefaultValidator
      include Beecart::Validator

      def run *args
        true
      end
    end
  end
end
