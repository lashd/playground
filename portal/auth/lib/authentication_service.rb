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
  class << self
    attr_accessor :session_service_url
  end
  format :json

  helpers Portal::Helpers::HttpOperations

  helpers do
    def send_create_session_request
      JSON.parse(http_post("#{AuthenticationService.session_service_url}").body)
    end

    def refresh_application_sessions token
      http_post("#{AuthenticationService.session_service_url}/#{token}")
    end
  end

  params do
    requires :credentials, :valid_credentials => true
  end

  post '/' do
    send_create_session_request
  end

  get '/:token' do
    response = refresh_application_sessions params[:token]
    throw(:error, :status => 404) unless response.status == 201
  end
end



