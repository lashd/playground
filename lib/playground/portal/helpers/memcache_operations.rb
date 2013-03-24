module Portal
  module Memcache
    class << self
      attr_accessor :host
    end
  end

  module Helpers
    module MemcacheOperations
      def memcache
        EventMachine::Protocols::Memcache.connect(::Portal::Memcache.host)
      end

      def set_in_cache key, value
        memcache.set(key, Marshal.dump(value))
      end

      def get_from_cache key
        Marshal.load(memcache.get(key))
      end
    end
  end

end