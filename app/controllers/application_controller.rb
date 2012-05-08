class ApplicationController < ActionController::Base
  protect_from_forgery

protected
  def mobile_device?
    AgentOrange::UserAgent.new(request.user_agent).device.is_mobile?
  end

  def authenticate_admin
    current_user && current_user.admin?
  end

  def admin?
    current_user && current_user.admin?
  end
  helper_method :admin?
end
