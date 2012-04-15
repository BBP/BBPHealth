class ApplicationController < ActionController::Base
  protect_from_forgery

protected
  def mobile_device?
    AgentOrange::UserAgent.new(request.user_agent).device.is_mobile?
  end

  def authenticate_admin
    authenticate_or_request_with_http_basic("Documents Realm") do |username, password|
      username == "admin" && password == "top_secret"
    end
  end
end
