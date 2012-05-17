require 'spec_helper'

describe "Medications" do
	before(:each) do
	  Medication.tire.index.delete
	  Medication.tire.index.create
	end
  describe "not logged in" do
  	it "should be login to creata a new medication" do
  		visit new_medication_path
  		current_path.should == new_user_session_path
  		page.should_not be_logged_in
  	end
  end

  describe "logged in" do
	  login

    it "should open new medication page" do
  		visit new_medication_path
  		current_path.should == new_medication_path
  		page.should be_logged_in
    end

    it "should create a new medication" do
    	lambda {
	  		visit new_medication_path
				fill_in "medication_name", with: "aspirine"
				fill_in "medication_generic_name", with: "aspirine"
				click_button I18n.t('helpers.submit.create')

				current_path.should == medication_path(Medication.last.slug)
				}.should change(Medication, :count)
    end
  end
end
