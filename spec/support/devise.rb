module ControllerMacros
  def login(user = nil)
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user ||= create(:user)
      sign_in @user
    end
  end  
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller
end
OmniAuth.config.test_mode = true
