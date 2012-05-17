module Concern
  module SecondaryEffects
    extend ActiveSupport::Concern

    included do
      include Mongoid::TaggableWithContext
      include Mongoid::TaggableWithContext::AggregationStrategy::RealTime

      taggable :secondary_effects, :separator => ','
    end

    module ClassMethods
      def analyze_secondary_effect_facets(result, term)
        result.facets['secondary_effects']["terms"].map! do |facet|
          facet['selected']     = term.include?(facet['term'])
          facet['remove_facet'] = (term - [facet["term"]])  * ","
          facet['add_facet']    = (term + [facet["term"]]) * ","
          facet
        end
      end
    end
  end
end
