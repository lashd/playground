module MemcacheOperations
  def memcache
    EventMachine::Protocols::Memcache.connect
  end
  def set_in_cache key, value
    memcache.set(key, Marshal.dump(value))
  end

  def get_from_cache key
    Marshal.load(memcache.get(key))
  end
end