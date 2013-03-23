require 'playground/portal/helpers/http_operations'
require 'grape'

class ValidCredentials < Grape::Validations::Validator
  def validate_param!(param, params)
    users = {'Bruce' => 'Arkham'}
    credentials = params.credentials
    user_password = users[credentials.username]

    throw(:error, :message => {:error => "user_not_found"}) if user_password.nil?
    throw(:error, :message => {:error => "invalid_password"}) if user_password != credentials.password
  end
end

class AuthenticationService < Grape::API
  format :json

  helpers Portal::Helpers::HttpOperations

  helpers do
    def send_create_session_request
      http_post("http://localhost:3000/sessions")
    end

    def refresh_application_sessions
      http = Faraday.new do |connection|
        connection.use Faraday::Adapter::EMSynchrony
      end
      http.post("http://localhost:3000/sessions/#{params[:token]}")
    end
  end

  params do
    requires :credentials, :valid_credentials => true
  end

  post '/' do
    send_create_session_request.body
  end

  get '/:token' do
    response = refresh_application_sessions
    throw(:error, :status => 404) unless response.status == 201
  end
end



