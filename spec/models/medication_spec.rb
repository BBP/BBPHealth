require 'spec_helper'
describe Medication do
  ##Fixme must be a cleaner way to do this in spec_helper.rb (is there a before (:models..?) ) We should probably contribute something to https://github.com/bmabey/database_cleaner
  before :each do
    Medication.tire.index.delete
    Medication.tire.index.create
  end

  it "should have no records in the beginning" do       
     Medication.all.length.should == 0
  end

  it "should validate there is a name" do                  
    medication = Medication.create()                        
    medication.save.should == false
  end

  it "should have no records in the search engine" do  
    medications = Medication.tire.search() do
      query { string "*" }
    end           
    medications.length.should == 0
  end     

  it "should have a slug" do                  
    medication = Medication.create!(:name=>"XxX")    
    medication.slug.should == "xxx"
  end
                    
  it "should not have the same slug" do     
    medication = Medication.create!(:name=>"XxX")                 
    medication = Medication.create!(:name=>"xxx")    
    medication.slug.should == "xxx-1"
  end
  
   it "should not allow a second medication with the same name" do                  
     medication = Medication.create(:name=>"xxx")    
     medication = Medication.create(:name=>"xxx")    
     medication.save.should  == false
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

  describe "location" do
    # it "should set position from lat/lng" do
    #   medication = Medication.create(:name => "name", :lat => 12, :lng => 14)
    #   medication.position.should == [14, 12]
    # end

    # it "should not set location if lat/lng are empty" do
    #   medication = Medication.create(:name => "name")
    #   medication.position.should be_nil

    #   medication = Medication.create(:name => "name 2", :lat => '', :lng => '')
    #   medication.position.should be_nil
    # end
  end

  describe "useragent" do
    it "should set user agent and detailed info" do
      useragent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.151 Safari/535.19"
      medication = Medication.create(:name => "name", :useragent => useragent)
      medication.useragent.should == useragent
      medication.useragent_info.should == {:device=>"Computer", :engine=>"AppleWebKit 535.19", :platform=>"Macintosh", :is_mobile=>false}
    end
  end
end
 
