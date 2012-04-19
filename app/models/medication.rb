class Medication
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::TaggableWithContext
  include Mongoid::Timestamps
  include Mongoid::TaggableWithContext::AggregationStrategy::RealTime
  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do 
    indexes :name
    indexes :generic_name
    # Define correct analyzer for secondary_effects array
    indexes :secondary_effects_array, :analyzer => 'keyword', :type => 'string'
  end

  # Fix to be able to use bonsai.io on heroku
#  Medication.index_name "bbphealth_#{Rails.env}"
  index_name BONSAI_INDEX_NAME if const_defined?(:BONSAI_INDEX_NAME)

  validates :name, :presence => true, :on => :create

  validates :name, :presence => true
  validates :name, :uniqueness => true

  attr_accessor :lat, :lng, :user_agent, :user

  slug :name, :permanent => true, :index => true
  
  # These Mongo guys sure do some funky stuff with their IDs
  # in +serializable_hash+, let's fix it.
  #
  def to_indexed_json
    self.to_json
  end
    
  field :name, :type => String
  field :generic_name, :type => String

  taggable :secondary_effects, :separator => ','   

  has_many :prescriptions

  after_create :create_prescription

  class << self
    def elastic_search(params)
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
    def paginate(options = {})
      page(options[:page]).per(options[:per_page])
    end
  end

  def update_tags!
    self.secondary_effects_array = prescriptions.map &:secondary_effects
    save!
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

  def create_prescription
    prescriptions.create!(lat: lat, lng: lng, user_agent: user_agent, user: user, secondary_effects: secondary_effects)
    # Prescription.tire.index.refresh
  end
end
