# -*- coding: utf-8 -*-

module Beecart

  def self.validators
    @varidators ||= []
  end

  module Validator
    def self.included(base)
      Beecart.validators << base
    end
  end
end
