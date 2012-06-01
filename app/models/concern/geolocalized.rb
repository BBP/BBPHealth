module Concern
  module Geolocalized
    extend ActiveSupport::Concern

    included do
      field :location, :type => Hash
      index [[ :location, Mongo::GEO2D ]], :min => -180, :max => 180
    end

    def lat=(value)
      self.location ||= {}
      self.location["latitude"] = value
    end

    def lng=(value)
      self.location ||= {}
      self.location["longitude"] = value
    end
    
    def lat
      location ? location["latitude"] : nil
    end

    def lng
      location ? location["longitude"] : nil
    end
  end
end
