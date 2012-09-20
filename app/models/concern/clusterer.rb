module Concern
  module Clusterer
    extend ActiveSupport::Concern

    class PointResource
      include HTTParty
      base_uri BBPHealth::Application.config.clusterer_url

      def initialize
        @auth = {:username => "M1v5cefH6ci9fFWubT1K", :password => "X"}
      end

      def post(point)
        options = { :query => {point: point.to_json }, :basic_auth => @auth}
        self.class.post("/api/maps/#{BBPHealth::Application.config.clusterer_key}/points.json", options)
      end

      def update(point)
        options = { :query => {point: point.to_json }, :basic_auth => @auth }
        self.class.put("/api/maps/#{BBPHealth::Application.config.clusterer_key}/points/#{point[:id]}.json", options)
      end

      def destroy(id)
        options = { :basic_auth => @auth }
        self.class.delete("/api/maps/#{BBPHealth::Application.config.clusterer_key}/points/#{id}.json", options)
      end
    end

    included do
      after_create  :create_clusterer
      after_update  :update_clusterer
      after_destroy :destroy_clusterer
    end

  private
    def resource
      @@resource ||= PointResource.new
    end

    def create_clusterer
      resource.post to_clusterer_json
    end

    def update_clusterer
      resource.update to_clusterer_json
    end

    def destroy_clusterer
      resource.destroy id
    end
  end
end
