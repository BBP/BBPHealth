RSpec::Matchers.define :be_logged_in do 
  match do |actual|
    actual.has_css?('.navbar-inner a', :text => I18n.t('devise.shared.sign_out'))
  end
  
  failure_message_for_should do |actual|
    "expected to be logged in"
  end

  failure_message_for_should_not do |actual|
    "expected not to be logged"
  end
end
