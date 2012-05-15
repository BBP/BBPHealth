require 'bbphealth/clustering'

class MapController < ApplicationController
  include BBPHealth::Clustering
  before_filter :find_medication

  def clusterize
    params[:mongo_condition] = {:medication_id => @medication.id}
    render :json => clusterize_response(params, @medication.prescriptions.collection), :callback => params[:callback]
  end

  def select
    render :json => {markers: [{html: 'TODO'}]}, :callback => params[:callback]
  end

private
  def find_medication
    @medication = Medication.find_by_slug(params[:id])
  end
end
