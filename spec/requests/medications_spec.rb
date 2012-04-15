require 'spec_helper'

describe "Medications" do
  describe "GET /medications" do
    it "works! (now write some real specs)" do
      get medications_path
      response.status.should be(200)
    end
  end
end
