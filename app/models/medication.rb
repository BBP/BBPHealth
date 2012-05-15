class Medication
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Timestamps

  include Concern::SecondaryEffects
  include Concern::Searchable

  field :name, :type => String
  field :generic_name, :type => String

  mapping do 
    indexes :name
    indexes :generic_name
    # Define correct analyzer for secondary_effects array
    indexes :secondary_effects_array, :analyzer => 'keyword', :type => 'string'
  end

  validates :name, :presence => true, :on => :create
  validates :name, :uniqueness => true

  attr_accessor :lat, :lng, :user_agent, :user
  attr_accessible :user_agent, :secondary_effects, :name, :generic_name, :lat, :lng

  slug :name, :permanent => true, :index => true

  has_many :prescriptions, dependent: :destroy

  after_create :create_prescription

  class << self
    def elastic_search(params)
      query = params[:q].present? ? "*#{params[:q]}*" : "*"
      t = params[:terms].present? ? params[:terms].split(',')  : []

      result = tire.search(page: params[:page], per_page: params[:per_page] || 10, load: true) do         
        query { string query, default_operator: "AND" } 
        filter :terms, :secondary_effects_array => t if t != [] 
        facet ("secondary_effects") { terms :secondary_effects_array, :global => false}
      end
      analyze_secondary_effect_facets result, t
      result
    end
  end

  def update_tags!
    self.secondary_effects_array = prescriptions.map(&:secondary_effects_array).flatten.uniq
    save!
  end

  def has_geo_data?
    prescriptions.where( location: {"$ne" => nil}).count > 0
  end

private
  def create_prescription
    prescriptions.create!(lat: lat, lng: lng, user_agent: user_agent, user: user, secondary_effects: secondary_effects)
  end
end
