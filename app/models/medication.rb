class Medication
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::TaggableWithContext
  include Mongoid::TaggableWithContext::AggregationStrategy::RealTime
  include Tire::Model::Search
  include Tire::Model::Callbacks

  # Fix to be able to use bonsai.io on heroku
  Medication.index_name '' if Rails.env.production?

  validates_presence_of :name   
  validates_uniqueness_of :name
  
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
