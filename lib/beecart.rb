require "singleton"

# require "beecart/engine"
require "beecart/configuration"
require "beecart/shopping_cart"
# require "beecart/controllers/core_ext"

module Beecart
  # class << self
  #   attr_accessor :configure

  #   #
  #   # @!attribute [rw] expire_time
  #   #   何秒でカートが消滅するか
  #   # @!attribute [rw] redis_conf
  #   #   接続するRedisへの情報
  #   #
  #   def expire_time=(val)
  #     @expire_time = val
  #   end

  #   def expire_time
  #     @expire_time
  #   end

  #   def redis_conf=(options)
  #     @redis_conf = options.inject(@redis_conf) do |res, (key, value)|
  #       @redis_conf[key] = value
  #       res
  #     end
  #   end

  #   def redis_conf
  #     @redis_conf
  #   end
  # end
end
