class Medication
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::TaggableWithContext
  include Mongoid::TaggableWithContext::AggregationStrategy::RealTime
    
  slug :name, 
    :permanent => true, # Don't change slug in the future
    :index => true
  
  field :name, :type => String
  field :generic_name, :type => String
  taggable :secondary_effects, :separator => ','                                                          
end
