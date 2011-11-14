class Medication
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::TaggableWithContext
  include Mongoid::TaggableWithContext::AggregationStrategy::RealTime
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  validates_presence_of :name   
  validates_uniqueness_of :name
  
  index_name ENV['RAILS_ENV'] + "medications"    
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
end
