class Prescription
  include Mongoid::Document
  include Mongoid::Timestamps

  include Concern::SecondaryEffects
  include Concern::Geolocalized
  include Concern::Searchable
  include Concern::Clusterer

  field :user_agent, :type => String
  field :user_agent_info, :type => Hash
  field :experience, :type => String

  belongs_to :user
  belongs_to :medication

  mapping do
    indexes :medication_id, type: 'string'
    indexes :secondary_effects_array, :analyzer => 'keyword', :type => 'string'
    indexes :created_at, type: 'date'
  end

  before_save :set_user_agent_info
  after_save :update_tags_and_index

  class << self
    def elastic_search(medication, params)
      t = params[:terms].present? ? params[:terms].split(',')  : []
      result = tire.search(page: params[:page], per_page: params[:per_page] || 10) do
        query do
          boolean do
            must { terms :secondary_effects_array => t } unless t.blank?
            must { term :medication_id, medication.id } if medication
          end
        end if medication || t.length > 0
        facet ("secondary_effects") { terms :secondary_effects_array, :global => false }
      end
      analyze_secondary_effect_facets result, t
      result
    end

    def with_secondary_effects
      where(:secondary_effects_array.ne => [])
    end
    def with_experience
      where(:experience.exists => true)
    end
  end

  def to_clusterer_json
    {
      id: id, lat: lat, lng: lng, created_at: created_at.to_i, secondary_effects: secondary_effects_array,
      user_id: user_id, medication_id: medication_id
    }
  end

private
  def set_user_agent_info
    if user_agent
      ua = AgentOrange::UserAgent.new(user_agent)
      self.user_agent_info = {device: ua.device.to_s, engine: ua.device.engine.to_s, platform: ua.device.platform.to_s, is_mobile: ua.device.is_mobile?}
    end
  end

  def update_tags_and_index
    medication.update_tags!
    update_index
  end
end

