# -*- coding: utf-8 -*-

module Beecart

  def self.validators
    @varidators ||= []
  end

  # Beecartの@validatorsに自身をPushする
  module Validator
    def self.included(base)
      Beecart.validators << base
    end
  end
end
