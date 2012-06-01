module Concern
  module Searchable
    extend ActiveSupport::Concern

    included do
      include Tire::Model::Search
      include Tire::Model::Callbacks
    
      index_name "#{self.to_s.tableize}_#{Rails.env}" unless Rails.env.production?
    end

    def to_indexed_json
      self.to_json
    end

    module ClassMethods
      # For Tire with kaminari
      def paginate(options = {})
        page(options[:page]).per(options[:per_page])
      end
    end
  end
end