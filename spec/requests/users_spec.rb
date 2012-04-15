require 'spec_helper'

describe "USer" do
  
  describe "Sign in" do
    before(:each) do
      @user = create(:user)
      visit root_path
      click_link I18n.t('devise.shared.sign_in')
    end

    it "should login valid credentials" do
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => @user.password
      click_button I18n.t("devise.shared.sign_in")

      page.current_path.should == root_path
      page.should be_logged_in
    end

    it "should not login invalid credentials" do
      fill_in 'user_email', :with => @user.email
      fill_in 'user_password', :with => "bad password"
      click_button I18n.t("devise.shared.sign_in")

      page.current_path.should == new_user_session_path
      page.should_not be_logged_in
    end
  end
  
  describe "Sign up" do
    before(:each) do
      visit root_path
      click_link I18n.t('devise.shared.sign_up')
    end
    it "should signup a valid user" do
      lambda {
        fill_in 'user_email', :with => Faker::Internet.email
        fill_in 'user_password', :with => "secret"
        fill_in 'user_password_confirmation', :with => "secret"
        click_button I18n.t("devise.shared.sign_up")

        page.current_path.should == root_path
        page.should be_logged_in
      }.should change(User, :count).by(1)
    end
    
    it "should not signup a invalid user" do
      lambda {
        fill_in 'user_email', :with => Faker::Internet.email
        fill_in 'user_password', :with => "secret"
        fill_in 'user_password_confirmation', :with => "secret_error"
        click_button I18n.t("devise.shared.sign_up")

        page.should_not be_logged_in
      }.should_not change(User, :count)
    end
  end
  
  describe "Sign out" do
    login
    it "should sign out a user" do
      visit root_path
      page.should be_logged_in
      
      click_link I18n.t('devise.shared.sign_out')
      page.should_not be_logged_in
    end
  end
    
  describe "Cancel account" do
    login

    it "should cancel account" do
      lambda {
        visit edit_user_registration_path
        click_link I18n.t('devise.registrations.cancel_my_account')
      
        page.current_path.should == root_path
        page.should_not be_logged_in
      }.should change(User, :count).by(-1)
    end    
  end


  describe "Edit account" do
    login
    it "should edit my account with valid info"  do
      visit edit_user_registration_path
      fill_in 'user_email', :with => "foo@bar.com"
      fill_in 'user_current_password', :with => "secret"
      click_button I18n.t("update")

      @user.reload.email.should == "foo@bar.com"
    end
      
    it "should not edit my account with invalid info" do
      visit edit_user_registration_path
      fill_in 'user_email', :with => "foo@bar.com"
      click_button I18n.t("update")

      @user.reload.email.should_not == "foo@bar.com"
    end
  end
end
