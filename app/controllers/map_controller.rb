require 'bbphealth/clustering'
class MapController < ApplicationController
  include BBPHealth::Clustering

  def clusterize
    render :json => clusterize_response(params), :callback => params[:callback]
  end

  def select
    render :json => {markers: [{html: 'TODO'}]}, :callback => params[:callback]
  end
end
