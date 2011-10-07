class Medication
  include Mongoid::Document
  include Mongoid::Slug
  
  slug :name, 
    :permanent => true, # Don't change slug in the future
    :index => true
  
  field :name, :type => String
  field :generic_name, :type => String
  field :secondary_effects, :type => String
end
