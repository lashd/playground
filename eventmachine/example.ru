require 'sinatra'

class MyCustomMiddleware

  def my_config_variable value=nil
    return @value unless value
    @value =value
  end

  def initialize app
    @app = app
    yield self
  end

  def call env
    puts "my middle ware being called here: #{my_config_variable}"
    @app.call env
  end
end

class ExampleApplication < Sinatra::Base
  use MyCustomMiddleware do |config|
    config.my_config_variable "!!!!!a value"
  end

  get '/' do
    "hello world"
  end

end

run ExampleApplication