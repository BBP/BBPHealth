module ControllerMacros
  def login(user = :user)
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(user)
      sign_in @user
    end
  end  

  def admin_login
    login(:admin)
  end
end

module RequestMacros
  def login(user = :user)
    before(:each) do
      @user = create(user) 
      visit new_user_session_path
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      click_button I18n.t("devise.shared.sign_in")
    end
  end   

  def admin_login
    login(:admin)
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller
  config.extend RequestMacros, :type => :request
end
OmniAuth.config.test_mode = true

