class Medication
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::TaggableWithContext
  include Mongoid::TaggableWithContext::AggregationStrategy::RealTime
  include Mongoid::Search
    
  slug :name, 
    :permanent => true, # Don't change slug in the future
    :index => true

  search_in :name, :generic_name, :secondary_effects
    
  field :name, :type => String
  field :generic_name, :type => String
  taggable :secondary_effects, :separator => ','                                                          
end
