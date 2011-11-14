require 'spec_helper'
##Fixme must be a cleaner way to do this in spec_helper.rb (is there a before (:models..?) ) We should probably contribute something to https://github.com/bmabey/database_cleaner
index = Tire::Index.new(ENV['RAILS_ENV'] + "medications")
index.delete
index.create
##
describe Medication do
  
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
     medication = Medication.create!(:name=>"XxX")    
     medication.slug.should == "xxx"
  end
                    
   it "should not have the same slug" do                  
     medication = Medication.create!(:name=>"xxx")    
     medication.slug.should == "xxx-1"
   end
  
   it "should not allow a second medication with the same name" do                  
     medication = Medication.create(:name=>"xxx")    
     medication.save.should  == false
  end

   it "should create 18 records" do  
     _medications_fixture.map{|med|
       medication = Medication.create(med)    
       medication.save
       }                
     Medication.all.length.should == 18
  end
                      
   it "it should have 18 records in the search engine" do  
     medications = Medication.tire.search() do
       query { string "*" }
     end    
     medications.total == 18
  end

   it "should validate there is a name" do                  
     medication = Medication.create()                        
     medication.save.should == false
  end

   it "should still have 18 records" do  
     _medications_fixture.map{|med|
       medication = Medication.create(med)    
       medication.save
       }                
     Medication.all.length.should == 18
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