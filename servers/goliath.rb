require 'goliath'
require 'grape'

class API < Grape::API
  format :json

  get '/' do
    {:success => true}
  end

end
class App < Goliath::API
  def response(env)
    ::API.call(env)
  end
end