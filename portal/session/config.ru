require "#{File.dirname(__FILE__)}/lib/session_service"
Portal::Memcache.host "localhost:11211"
run SessionService