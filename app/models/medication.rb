class Medication
  include Mongoid::Document
  field :name, :type => String
  field :generic_name, :type => String
  field :secondary_effects, :type => String
end
