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
      _medications_fixture.map { |med|
        medication = Medication.create(med)    
        medication.save
      }                
    end
    
    it "should create 16 records" do  
      Medication.all.length.should == _medications_fixture.length
    end
                      
     it "it should have 16 records in the search engine" do  
       medications = Medication.tire.search() do
         query { string "*" }
       end    
       medications.total == _medications_fixture.length
    end
  end

  describe "location" do
    it "should set position from lat/lng" do
      medication = Medication.create(:name => "name", :lat => 12, :lng => 14)
      medication.position.should == [14, 12]
    end

    it "should not set location if lat/lng are empty" do
      medication = Medication.create(:name => "name")
      medication.position.should be_nil

      medication = Medication.create(:name => "name 2", :lat => '', :lng => '')
      medication.position.should be_nil
    end
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
 
def _medications_fixture
  [{
      :generic_name=> "Aspirine 1",
      :name=> "Aspergel",
      :secondary_effects=> "Mal au dos,Yeux rouges,Rougeur,Faim,Mort subite",
  },
  {
      :generic_name=> "Paracetamol 2",
      :name=> "Doliprane",
      :secondary_effects=> "Rougeur,Faim,Soif",
  },
  {

      :generic_name=> "Dopamine 3",
      :name=> "Dopaminston",
      :secondary_effects=> "Soif",
      :slug=> "im"
  },
  {

      :generic_name=> "Histamine 4",
      :name=> "Vericaridon",
      :secondary_effects=> "Mort subite,Rougeur",
      :slug=> "lll"
  },
  {
      :generic_name=> "Ibupropen 5",
      :name=> "Nurofen",
      :secondary_effects=> "Faim",
  },
  {
      :generic_name=> "Elasticene 6",
      :name=> "Similisen",
      :secondary_effects=> "Gloire",
  },
  {
      :generic_name=> "Elasticene I 7",
      :name=> "Similisen I",
      :secondary_effects=> "Gloire",
  },
  {
      :generic_name=> "Elasticene II 8",
      :name=> "Similisen II",
      :secondary_effects=> "Gloire",
  },
  {
      :generic_name=> "Elasticene III 9",
      :name=> "Similisen III",
      :secondary_effects=> "Gloire",
  },

  {
      :generic_name=> "Elasticene IV 10",
      :name=> "Similisen IV",
      :secondary_effects=> "Gloire",
  },

  {
      :generic_name=> "Elasticene V 11",
      :name=> "Similisen V",
      :secondary_effects=> "Gloire",
  },

  {
      :generic_name=> "Elasticene VI 12",
      :name=> "Similisen VI",
      :secondary_effects=> "Gloire",
  },

  {
      :generic_name=> "Elasticene VII 13",
      :name=> "Similisen VII",
      :secondary_effects=> "Gloire",
  },

  {
      :generic_name=> "Elasticene VIII 14",
      :name=> "Similisen VIII",
      :secondary_effects=> "Gloire",
  },

  {
      :generic_name=> "Elasticene IX 15",
      :name=> "Similisen IX",
      :secondary_effects=> "Gloire",
  },

  {
      :generic_name=> "Elasticene X 16",
      :name=> "Similisen X",
      :secondary_effects=> "Gloire",
  }]
end