require "omniauth-facebook"
Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development?
    provider :facebook, '362807127093790', 'a3d57d6c1bd18e65c01b0e6fe2900332', :setup => true, scope: "email,user_birthday,user_about_me"
  elsif Rails.env.production?
    provider :facebook, '334294033301652', '8606d936d9557b892a5c42c605e83aa2', :setup => true, scope: "email,user_birthday,user_about_me"
  end
end
OmniAuth.config.logger = Rails.logger
