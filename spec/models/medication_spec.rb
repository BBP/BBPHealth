require 'spec_helper'
describe Medication do
  ##Fixme must be a cleaner way to do this in spec_helper.rb (is there a before (:models..?) ) We should probably contribute something to https://github.com/bmabey/database_cleaner
  before :each do
    Medication.tire.index.delete
    Medication.tire.index.create
  end

  it {should validate_presence_of(:name)}
  it {should validate_uniqueness_of(:name)}

  it "should create a prescription with same secondary effects" do
    medication = create(:medication, :secondary_effects => "foo,bar")    
    medication.prescriptions.length.should == 1

    prescription = medication.prescriptions.first
    prescription.user.should == medication.user
    prescription.secondary_effects.should == medication.secondary_effects
  end

  it "should have no records in the beginning" do       
     Medication.all.length.should == 0
  end

  it "should have no records in the search engine" do  
    medications = Medication.tire.search() do
      query { string "*" }
    end           
    medications.length.should == 0
  end     

  it "should have a slug" do                  
    medication = create(:medication, :name=>"XxX")    
    medication.slug.should == "xxx"
  end
                    
  it "should not have the same slug" do     
    medication = create(:medication, :name=>"XxX")                 
    medication = create(:medication, :name=>"xxx")    
    medication.slug.should == "xxx-1"
  end

  it "should not have gea data without localized prescription" do
    create(:medication).should_not have_geo_data
  end

  it "should have gea data with localized prescription" do
    medication = create(:medication)
    create(:prescription, medication: medication, lat: 10, lng: 10)
    medication.should have_geo_data
  end
  
  describe "search engine" do
    before(:each) do
      1.upto(16) { create(:medication) }
    end
    
    it "should create 16 records" do  
      Medication.all.length.should == 16
    end
                      
     it "it should have 16 records in the search engine" do  
       medications = Medication.tire.search() do
         query { string "*" }
       end    
       medications.total == 16
    end
  end

  describe "user_agent" do
    it "should set user agent and detailed info" do
      user_agent   = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.151 Safari/535.19"
      medication   = create(:medication, :user_agent => user_agent)
      prescription = medication.prescriptions.first
      prescription.user_agent.should == user_agent
      prescription.user_agent_info.should == {:device=>"Computer", :engine=>"AppleWebKit 535.19", :platform=>"Macintosh", :is_mobile=>false}
    end
  end
end
 
