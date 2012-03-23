require 'tire'

# Horrible monckey patch for bonzai to avoid double / in URL
# Should make a push request
module Tire
  class Index
    def store(*args)
      document, options = args
      type = get_type_from_document(document)

      if options
        percolate = options[:percolate]
        percolate = "*" if percolate === true
      end

      id       = get_id_from_document(document)
      document = convert_document_to_json(document)

      # Change that to avoid double / in URL, bonsai.io don't like that
      url  = "#{Configuration.url}#{(id ? "/#{@name}/#{type}/#{id}" : "/#{@name}/#{type}/").squeeze('/')}"
      url += "?percolate=#{percolate}" if percolate

      @response = Configuration.client.post url, document
      MultiJson.decode(@response.body)

    ensure
      curl = %Q|curl -X POST "#{url}" -d '#{document}'|
      logged([type, id].join('/'), curl)
    end
  end
end

Tire.configure do
   logger STDERR
   url(YAML::load(File.open(Rails.root.join("./config/tire.yml")))[Rails.env]["url"])
end
Tire::Model::Search.index_prefix "#{Rails.env}".downcase unless Rails.env.production?
