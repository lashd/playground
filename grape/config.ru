require 'grape'

class App < Grape::API
  #Grape::API.logger.level=Logger.new $stdout
  format :txt

  params do
    optional :email, :type => String
  end
  get '/'do
    content_type 'text/plain'
    "hello"
  end

  rescue_from :all do |e|
    puts e
  end

end

run App