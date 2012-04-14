Dir[File.join(Rails.root, 'config', 'locales', '**', '*.yml')].each do |file|
  I18n.load_path << file
end
module I18n 
  def self.just_raise(*args) 
    raise args.first 
  end 
end 
# I18n.exception_handler = :just_raise
AVAILABLE_LOCALES = [:en, :fr]
I18n.available_locales = AVAILABLE_LOCALES

I18n.default_locale = :fr
I18n.locale = :fr

I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
I18n.fallbacks.map('fr' => 'en')

# To avoid to add :locale in url helpers
module ActionDispatch
  module Routing
    module UrlFor
      alias_method :url_for_without_locale, :url_for unless method_defined?(:url_for_without_locale)
      def url_for(options = nil)
        options ||= {}
        options.merge!(:locale => I18n.locale) unless I18n.locale == I18n.default_locale || options.is_a?(String)
        url_for_without_locale(options)
      end
    end
  end
end
