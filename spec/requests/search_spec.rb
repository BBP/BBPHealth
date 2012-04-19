require 'spec_helper'

describe "Search" do
  before(:each) do
    @medications = []
    @medications << create(:medication, :name => "ibuprofene", :generic_name => "ibuprofene")
    @medications << create(:medication, :name => "asprin", :generic_name => "asprin")

    visit root_path
  end
  it "should search for a medication" do
    fill_in "search-text", :with => "ibu"
    click_button "search-button"

    current_path.should == medications_elastic_search_path
    page.should have_css("td", :text => "ibuprofene")
    page.should_not have_css("td", :text => "asprin")
  end
end