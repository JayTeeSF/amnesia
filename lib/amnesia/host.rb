module Amnesia
  class Host
    def initialize(address)
      @address = address
    end

    def alive? 
      return true if connection.stats && connection.stats.values.first && connection.stats.values.first
    rescue Memcached::Error
      return false
    end

    def method_missing(method, *args)
      stats[method.to_s].to_i
    end

    def stats
      connection.stats[address]
    rescue Memcached::Error
      return {}
    end

    def address
      @address || @connection.servers.join(', ')
    end

    private

    def bogus_cache
      Module.new.module_eval { extend self; def stats; false; end }
    end

    def connection
      @connection ||= @address ? Dalli::Client.new(@address) : bogus_cache
    end
  end
end
