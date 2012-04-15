class Medication
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::TaggableWithContext
  include Mongoid::Timestamps
  include Mongoid::TaggableWithContext::AggregationStrategy::RealTime
  include Tire::Model::Search
  include Tire::Model::Callbacks

  # Fix to be able to use bonsai.io on heroku
  Medication.index_name "medications_#{Rails.env}"

  validates_presence_of :name   
  validates_uniqueness_of :name

  attr_accessor :lat, :lng
  before_save :set_position
  before_save :set_useragent_info

  mapping do 
    indexes :name
    indexes :generic_name
    # Define correct analyzer for secondary_effects array
    indexes :secondary_effects_array, :analyzer => 'keyword', :type => 'string'
  end
  slug :name, :permanent => true, :index => true
  
  # These Mongo guys sure do some funky stuff with their IDs
  # in +serializable_hash+, let's fix it.
  #
  def to_indexed_json
    self.to_json
  end
    
  field :name, :type => String
  field :generic_name, :type => String

  field :useragent, :type => String
  field :useragent_info, :type => Hash
  taggable :secondary_effects, :separator => ','   

  field :position, :type => Array
  index [[ :position, Mongo::GEO2D ]], :min => -180, :max => 180

  has_many :prescriptions

  def self.elastic_search(params)
    query = params[:q].present? ? "*#{params[:q]}*" : "*"
    t = params[:terms].present? ? params[:terms].split(',')  : []

    result = tire.search(page: params[:page], per_page: params[:per_page] || 10) do         
      query { string query, default_operator: "AND" } 
      filter :terms, :secondary_effects_array => t if t != [] 
      facet ("secondary_effects") { terms :secondary_effects_array, :global => false}
    end
    analyze_facets result, t
    result
  end

  # For Tire with kaminari
  def self.paginate(options = {})
    page(options[:page]).per(options[:per_page])
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

  def set_useragent_info
    if useragent
      ua = AgentOrange::UserAgent.new(useragent)
      self.useragent_info = {device: ua.device.to_s, engine: ua.device.engine.to_s, platform: ua.device.platform.to_s, is_mobile: ua.device.is_mobile?}
    end
  end
end
