require 'grape'

class App < Grape::API
  ::Grape::API.logger.level=Logger.new $stdout
  get '/' do
    puts "hello"
  end

  rescue_from :all do |e|
    puts e
  end

end

run App