require "cartbee/engine"

require "cartbee/models/shopping_cart"
require "cartbee/controllers/core_ext"

module Cartbee
  @expire_time = 20 * 60
  @redis_conf  = {
    host: 'localhost',
    port: 5555
  }

  class << self
    def expire_time=(val)
      @expire_time = val
    end

    def expire_time
      @expire_time
    end

    def redis_conf=(options)
      @redis_conf = options.inject(@redis_conf) do |res, (key, value)|
        @redis_conf[key] = value
        res
      end
    end

    def redis_conf
      @redis_conf
    end
  end

end
