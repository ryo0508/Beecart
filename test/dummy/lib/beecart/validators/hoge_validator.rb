# -*- coding: utf-8 -*-

module Beecart
  module Validators
    class HogeValidator < Beecart::Validators::BaseValidator
      def run args
        puts '---------- hoge_validator start ----------'

        puts args

        args.each do |k, v|
          puts "k => #{ k }"
          puts "v => #{ v }"
        end

        if args["value_1"] != "hoge"
          record_error "#{ args["value_1"] } is not suitable for value_1", "value_1"
        end

        if args["value_2"] == "hoge"
          record_error "#{ args["value_2"] } is not suitable for value_2", "value_2"
        end

        puts '---------- hoge_validator  end  ----------'

        super
      end
    end
  end
end
