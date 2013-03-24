require 'event_machine'
require 'em-synchrony/em-memcache'
module Portal
  module Memcache
    class << self
      attr_accessor :host

      def connection
        @connection ||= EventMachine::Protocols::Memcache.connect(host)
      end
    end
  end

  module Helpers
    module MemcacheOperations
      def memcache
        ::Portal::Memcache.connection
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