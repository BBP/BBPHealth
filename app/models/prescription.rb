class Prescription
  include Mongoid::Document
  include Tire::Model::Search
  include Tire::Model::Callbacks

  include Mongoid::TaggableWithContext
  include Mongoid::Timestamps
  include Mongoid::TaggableWithContext::AggregationStrategy::RealTime

  attr_accessor :lat, :lng
  before_save :set_position
  before_save :set_user_agent_info

  belongs_to :user
  belongs_to :medication

  field :position, :type => Array
  index [[ :position, Mongo::GEO2D ]], :min => -180, :max => 180

  field :user_agent, :type => String
  field :user_agent_info, :type => Hash
  taggable :secondary_effects, :separator => ','   

  mapping do 
    indexes :medication_id, type: 'integer'
    # Define correct analyzer for secondary_effects array
    indexes :secondary_effects_array, :analyzer => 'keyword', :type => 'string'
  end
  
  def to_indexed_json
    self.to_json
  end

  class << self
    def elastic_search(medication, t = [])
      result = tire.search(page: params[:page], per_page: params[:per_page] || 0) do   
        query do
          boolean do
            must { terms :secondary_effects_array => t } unless t.blank? 
            must { term :medication_id, medication.id } if medication
          end
        end
        facet ("secondary_effects") { terms :secondary_effects_array, :global => false}
      end
      analyze_facets result, t
      result
    end
  end

private
  def self.analyze_facets(result, term)
    result.facets['secondary_effects']["terms"].map! do |facet|
      facet['selected']     = term.include?(facet['term'])
      facet['remove_facet'] = (term - [facet["term"]])  * ","
      facet['add_facet']    = (term + [facet["term"]]) * ","
      facet
    end
  end

  def set_position
    self.position = [lng, lat] unless lat.blank? || lng.blank?
  end

  def set_user_agent_info
    if user_agent
      ua = AgentOrange::UserAgent.new(user_agent)
      self.user_agent_info = {device: ua.device.to_s, engine: ua.device.engine.to_s, platform: ua.device.platform.to_s, is_mobile: ua.device.is_mobile?}
    end
  end
end

