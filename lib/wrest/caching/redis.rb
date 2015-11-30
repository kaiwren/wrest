begin
  gem 'redis', '~> 3'
rescue Gem::LoadError => e
  Wrest.logger.debug "Redis ~> 3 not found. The Redis gem is necessary to use redis as a caching back-end."
  raise e
end

require 'redis'
require 'yaml'

module Wrest::Caching
  class Redis

    def initialize(redis_options = {})
      @redis = ::Redis.new(redis_options)
    end

    def [](key)
      value = @redis.get(key)
      unmarshalled_value = value.nil? ? nil : YAML::load(value)
      unmarshalled_value
    end

    def []=(key, value)
      marshalled_value = YAML::dump(value)
      @redis.set(key, marshalled_value)
    end
    
    def delete(key)
      value = self[key]
      
      @redis.del(key)

      return value
    end
  end
end