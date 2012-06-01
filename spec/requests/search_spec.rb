require 'spec_helper'

describe "Search" do
  before(:each) do
    Prescription.tire.index.delete
    Prescription.tire.index.create

    Medication.tire.index.delete
    Medication.tire.index.create

    @medications = []
    @medications << create(:medication, :name => "ibuprofene", :generic_name => "ibuprofene")
    @medications << create(:medication, :name => "asprin", :generic_name => "asprin")

    Medication.tire.index.refresh
    visit root_path
  end

  it "should search for a medication" do
    fill_in "search-text", :with => "ibu"
    find("#search-button").click
    current_path.should == elastic_search_medications_path


    page.should have_css("h3", :text => "ibuprofene")
    page.should_not have_css("h3", :text => "asprin")
  end
end