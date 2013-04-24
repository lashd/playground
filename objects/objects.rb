require 'logger'
local_variable = 'local'
$global = 'global'
CONSTANTS = 'constant'
@attribute = 'attribute'
@@class_wide = 'class wide'


module Logging

  def self.included clazz
    class << clazz
      attr_accessor :logger
    end
  end

  def log message
    self.class.logger.info(message)
  end

end

class AuthenticationService
  include Logging

  def login
    log "Someone has logged in!!!"
  end

  alias_method :login_alias, :login

  def login
    puts "a copy!!"
    login_alias
  end


end

AuthenticationService.logger = Logger.new(STDOUT)
app = AuthenticationService.new
app.login
