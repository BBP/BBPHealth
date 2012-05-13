module BBPHealth
  class MercatorProjection
    TILE_SIZE_PX       = 256
    MAX_LAT            = 85.05113
    RADIANS_PER_DEGREE = Math::PI / 180
    LOG_360            = Math.log(360)
    LOG_2              = Math.log(2)

    def self.zoom_for(geo_width, viewport_width)
      tile_geo_width = geo_width * TILE_SIZE_PX / viewport_width
      ((LOG_360 - Math.log(tile_geo_width)) / LOG_2).round
    end

    def initialize(zoom)
      @zoom = zoom

      earthCircumferencePx = (2 ** zoom) * TILE_SIZE_PX
      @earth_half_radius_px = earthCircumferencePx / (4 * Math::PI)
      @longitude_px_per_degrees = earthCircumferencePx / 360.0
    end

    def resolution_for(groupingDistance)
      # 8 = log(256) / log(2)
      resolution = (@zoom + 8 - Math.log(groupingDistance) / LOG_2).floor
      resolution < 0 ? 0 : resolution
    end

    def horizontal_distance(lng1, lng2)
      ((lng1 - lng2).abs * @longitude_px_per_degrees).round
    end

    def vertical_distance(lat1, lat2)
      (lat_to_y(lat1) - lat_to_y(lat2)).abs.round
    end

  private
    def lat_to_y(lat)
      x = Math.sin(lat * RADIANS_PER_DEGREE)
      @earth_half_radius_px * Math.log((1 + x) / (1 - x))
    end
  end
end
