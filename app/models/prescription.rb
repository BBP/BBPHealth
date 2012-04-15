class Prescription
  include Mongoid::Document
  belongs_to :user
  belongs_to :medication

  field :position, :type => Array
  index [[ :position, Mongo::GEO2D ]], :min => -180, :max => 180
end

