require "spec_helper"

describe MedicationsController do
  describe "routing" do

    it "routes to #index" do
      get("/medications").should route_to("medications#index", "locale"=>"")
    end

    it "routes to #new" do
      get("/medications/new").should route_to("medications#new", "locale"=>"")
    end

    it "routes to #show" do
      get("/medications/1").should route_to("medications#show", :id => "1", "locale"=>"")
    end

    it "routes to #edit" do
      get("/medications/1/edit").should route_to("medications#edit", :id => "1", "locale"=>"")
    end

    it "routes to #create" do
      post("/medications").should route_to("medications#create", "locale"=>"")
    end

    it "routes to #update" do
      put("/medications/1").should route_to("medications#update", :id => "1", "locale"=>"")
    end

    it "routes to #destroy" do
      delete("/medications/1").should route_to("medications#destroy", :id => "1", "locale"=>"")
    end

  end
end
