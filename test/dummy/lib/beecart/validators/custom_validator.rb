# -*- coding: utf-8 -*-

module Beecart
  module Validators
    class CustomValidator

      include Beecart::Validator

      def run *args
        puts '---------- custom_validator start ----------'
        puts '---------- custom_validator  end  ----------'
        true
      end
    end
  end
end
