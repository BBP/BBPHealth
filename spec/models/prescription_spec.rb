require 'spec_helper'
describe Prescription do
  it "should create a simple prescription" do
    prescription = create(:prescription)
    prescription.should be_valid
  end

  describe "location" do
    it "should not set location by default" do
      prescription = create(:prescription)
      prescription.lat.should be_nil
      prescription.lng.should be_nil
    end

    it "should set location and compute path" do
      prescription = create(:prescription, lat: 12, lng: 13)
      prescription.location.should == {"latitude" => 12, "longitude" => 13}
      prescription.lat.should == 12
      prescription.lng.should == 13
    end
  end
end