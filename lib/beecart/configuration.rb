require "logger"

module Beecart
  class Configuration
    include Singleton

    def self.default_logger
      logger = Logger.new(STDOUT)
      logger.progname = "beecart"
      logger
    end

    @@defaults = {
      logger: default_logger,
      expire_time: 30 * 60,
      redis: {
        host: 'localhost',
        port: 5555
      }
    }

    def self.defaults
      @@defaults
    end

    def initialize
      @@defaults.each_pair{|k,v| self.send("#{k}=",v)}
    end

    def redis=(options={})
      if @redis && @redis.is_a?(Hash)
        @redis = @redis.merge(options)
      else
        @redis = options
      end
    end

    attr_reader :redis
    attr_accessor :logger, :expire_time
  end

  def self.config
    Configuration.instance
  end

  def self.configure
    yield config
  end

  def self.logger
    config.logger
  end
end
