require "omniauth-facebook"
Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development?
    provider :facebook, '362807127093790', 'a3d57d6c1bd18e65c01b0e6fe2900332', :setup => true
  end
end
OmniAuth.config.logger = Rails.logger
