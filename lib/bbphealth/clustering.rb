require 'bbphealth/mercator_projection'
module BBPHealth
  module Clustering
    MAP_METHOD = <<-MAP
      emit(this.path.substr(0, resolution), 
           {sw_lat: this.location.latitude, 
            sw_lng: this.location.longitude, 
            ne_lat: this.location.latitude, 
            ne_lng: this.location.longitude, 
            id: this._id,
            count: 1 });
    MAP

    REDUCE_METHOD = <<-REDUCE
      function reduce(key, values) {
        var value = values[0], result = { count: 0, sw_lat: value.sw_lat, sw_lng: value.sw_lng, ne_lat: value.ne_lat, ne_lng: value.ne_lng};
        for (var i = values.length - 1; i>=0; i--) {
          var value = values[i];
          result.sw_lat = Math.min(result.sw_lat, value.sw_lat);
          result.sw_lng = Math.min(result.sw_lng, value.sw_lng);
          result.ne_lat = Math.max(result.ne_lat, value.ne_lat);
          result.ne_lng = Math.max(result.ne_lng, value.ne_lng);
          result.count += value.count;
        }
        return result;
      }
    REDUCE
    
    FINALIZE_METHOD = <<-FINALIZE
      function(obj, val) {
        if (val.count == 1) {
          return {count: 1, id: val.id, lat: val.sw_lat, lng: val.sw_lng}
        } else {
          return {
            lat: (val.sw_lat + val.ne_lat) / 2,
            lng: (val.sw_lng + val.ne_lng) / 2,
            count: val.count ,
            sw_lat: val.sw_lat,
            sw_lng: val.sw_lng,
            ne_lat: val.ne_lat,
            ne_lng: val.ne_lng
          }          
        }
      }
    FINALIZE

    def clusterize_response(params, collection)
      viewport = params["viewport"].split(',').map &:to_i
      ne       = params["ne"].split(',').map &:to_f 
      sw       = params["sw"].split(',').map &:to_f 

      projection        = MercatorProjection.new(MercatorProjection.zoom_for(ne[1] - sw[1], viewport[0]))
      grouping_distance = (params["groupingDistance"] || 20).to_i
      query             = bounds_conditions(sw, ne)
      query.merge!(Rack::Utils.parse_nested_query(params["condition"]))
      query.merge!(params["mongo_condition"])
      result = collection.map_reduce(MAP_METHOD, REDUCE_METHOD, 
                                     finalize: FINALIZE_METHOD, 
                                     out: {inline: true}, 
                                     raw: true, 
                                     query: query,
                                     scope: {resolution: projection.resolution_for(grouping_distance)})
      result["results"].map! { |p| p["value"] }
      build_maptimize_response perform_further_grouping(projection, grouping_distance, result["results"])
    end

  private
    def bounds_conditions(sw, ne)
      { 
        "location.latitude"  => { "$gte" => sw[0] - 0.00001, "$lte" => ne[0] + 0.00001 }, 
        "location.longitude" => { "$gte" => sw[1] - 0.00001, "$lte" => ne[1] + 0.00001 } 
      }
    end

    def perform_further_grouping(projection, distance, data)
      data.sort! {|x,y| x["lat"] <=> y["lat"] }
      i = 0
      while i < data.length
        j = i - 1
        current = data[i]
        while j >= 0
          previous = data[j]
          j -= 1
          break if projection.vertical_distance(previous["lat"], current["lat"]) > distance
          next if  projection.horizontal_distance(previous["lng"], current["lng"]) > distance
          merge_data(current, previous)
          data.delete(previous)
        end
        i += 1
      end
      data
    end

    def merge_data(source, dest)
      # Update count
      source["count"] += dest["count"]
      source["lat"] = (source["lat"] * source["count"] + dest["lat"] * dest["count"]) / (source["count"] + dest["count"])
      source["lng"] = (source["lng"] * source["count"] + dest["lng"] * dest["count"]) / (source["count"] + dest["count"])

      source["sw_lat"] = [source["sw_lat"] || source["lat"], dest["sw_lat"] || dest["lat"]].min
      source["sw_lng"] = [source["sw_lng"] || source["lng"], dest["sw_lng"] || dest["lng"]].min
      source["ne_lat"] = [source["ne_lat"] || source["lat"], dest["ne_lat"] || dest["lat"]].max
      source["ne_lng"] = [source["ne_lng"] || source["lng"], dest["ne_lng"] || dest["lng"]].max

      source.delete("id")
    end

    def build_maptimize_response(results)
      maptimize = {:clusters => [], :markers => [], :success => true}
      results.each do |point|
        if point["count"] == 1 
          maptimize[:markers] << {:id => point["id"], :coords => "#{point["lat"]}, #{point["lng"]}"}
        else
         maptimize[:clusters] << {:coords => "#{point["lat"]}, #{point["lng"]}", :count => point["count"],
                                  :bounds => {:ne => "#{point["ne_lat"]}, #{point["ne_lng"]}", :sw => "#{point["sw_lat"]}, #{point["sw_lng"]}"}}
        end
      end
      maptimize
    end
  end
end
