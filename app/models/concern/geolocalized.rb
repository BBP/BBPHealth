module Concern
  module Geolocalized
    extend ActiveSupport::Concern

    included do
      before_save :set_location

      field :location, :type => Hash
      index [[ :location, Mongo::GEO2D ]], :min => -180, :max => 180

      field :path
      index :path

      attr_accessor :lat, :lng
    end

    def lat
      location ? location.latitude : nil
    end

    def lng
      location ? location.longitude : nil
    end
    
    def set_location
      unless lat.blank? || lng.blank?
        self.lat      = self.lat.to_f
        self.lng      = self.lng.to_f
        self.location = {latitude: lat, longitude:lng} 
        self.path     = self.class.path(lat, lng) 
      end
    end
    private :set_location

    module ClassMethods
      def path(lat, lng, level = 25)
        if level == 0
          ''
        else
          # 0, 1, 2 or 3
          local_path = ((lat >= 0 ? 0 : 2) + (lng < 0 ? 0 : 1)).to_s
          # followed by level-1 path of subnode centered on current node
          local_path << path(lat % 90 * 2 - 90, lng % 180 * 2 - 180, level-1)
        end
      end
    end
  end
end
