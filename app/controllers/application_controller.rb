class ApplicationController < ActionController::Base
  protect_from_forgery

protected
  def mobile_device?
    AgentOrange::UserAgent.new(request.user_agent).device.is_mobile?
  end
end
