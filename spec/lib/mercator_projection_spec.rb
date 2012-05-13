require 'spec_helper'
require 'bbphealth/mercator_projection'

describe BBPHealth::MercatorProjection do
  it "should get resolution for grouping distance zoom 0" do
    p = BBPHealth::MercatorProjection.new(0)
    p.resolution_for(256).should == 0
    p.resolution_for(192).should == 0
    p.resolution_for(168).should == 0

    p.resolution_for(128).should == 1
    p.resolution_for(96).should  == 1
    p.resolution_for(80).should  == 1

    p.resolution_for(64).should  == 2
  end

  it "should get resolution for grouping distance zoom 3" do
    p = BBPHealth::MercatorProjection.new(3)
    p.resolution_for(256).should == 3
    p.resolution_for(192).should == 3
    p.resolution_for(168).should == 3

    p.resolution_for(128).should == 4
    p.resolution_for(96).should  == 4
    p.resolution_for(80).should  == 4

    p.resolution_for(64).should  == 5
  end

  it "should get zoom from bouds/viewport with" do
    BBPHealth::MercatorProjection.zoom_for(0.49713134765625, 1446).should == 12
  end

  it "should get horizontal distance" do
    p = BBPHealth::MercatorProjection.new(12)
    p.horizontal_distance(7.008769, 7.505901).should == 1448

    p = BBPHealth::MercatorProjection.new(10)
    p.horizontal_distance(6.263072, 8.251598).should == 1448
  end

  it "should get vertical distance" do
    p = BBPHealth::MercatorProjection.new(12)
    p.vertical_distance(43.641667, 43.79105).should == 602

    p = BBPHealth::MercatorProjection.new(10)
    p.vertical_distance(43.416896, 44.014424).should == 602
  end
end
