require 'spec_helper'
require 'bbphealth/clustering'

describe BBPHealth::Clustering do
  class Engine
    include BBPHealth::Clustering
  end
  
  describe "clusterize" do
    before(:each) do
      @medication    = create(:medication)
      @prescription1 = create(:prescription, medication: @medication, :lat => 10, :lng => 10)
      @prescription2 = create(:prescription, medication: @medication, :lat => 12, :lng => 12)

      @engine = Engine.new
      @params = {"ne"=>"89.988124,179.999999", "sw"=>"-89.97661,-179.999999", "viewport" => "300,300", "callback"=>"com.maptimize.callbacks._0", "groupingDistance"=>"30"}
    end

    it "should clusterize data and create a cluster" do
      response = @engine.clusterize_response @params
      response[:success].should  be_true
      response[:markers].should be_empty
      response[:clusters].should == [{:coords=>"11.0, 11.0", :count=>2.0, :bounds=>{:ne=>"12.0, 12.0", :sw=>"10.0, 10.0"}}]
    end
    
    it "should clusterize data and keep 2 markers" do
      response = @engine.clusterize_response @params.merge("sw"=>"9,9", "ne"=>"13, 13")
      response[:success].should  be_true
      response[:markers].should  =~ [{:coords => "10.0, 10.0", :id => @prescription1.id},
                                     {:coords => "12.0, 12.0", :id => @prescription2.id}]
      response[:clusters].should == []
    end    
  end
end