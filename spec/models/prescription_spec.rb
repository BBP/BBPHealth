require 'spec_helper'
describe Prescription do
  before :each do
    Prescription.tire.index.delete
    Prescription.tire.index.create
  end

  it "should create a simple prescription" do
    prescription = create(:prescription)
    prescription.should be_valid
  end

  describe "location" do
    it "should not set location by default" do
      prescription = create(:prescription)
      prescription.lat.should be_nil
      prescription.lng.should be_nil
      prescription.path.should be_nil
    end

    it "should set location and compute path" do
      prescription = create(:prescription, lat: 12, lng: 13)
      prescription.lat.should == 12
      prescription.lng.should == 13
      prescription.path.should == "1220322122313330322122313"
      prescription.location.should == {latitude: 12, longitude: 13}
    end
  end
end