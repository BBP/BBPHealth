require 'tire'

# Monkey-patch for bonsai.io on heroku
class HerokuRestClient < Tire::HTTP::Client::RestClient
	class << self
		def cleanup_url(url) 
			# remove duplicated // but not the one in http://
			url[0...7] + url[7..-1].squeeze('/')
		end

	  def get(url, data=nil)
	  	super(cleanup_url(url), data)
	  end

	  def post(url, data)
	  	super(cleanup_url(url), data)
	  end

	  def put(url, data)
	  	super(cleanup_url(url), data)
	  end

	  def delete(url)
	  	super(cleanup_url(url))
	  end

	  def head(url)
	  	super(cleanup_url(url))
	  end
	end
end

Tire.configure do
   if Rails.env.production? || Rails.env.staging?
	   logger STDERR, :level => 'debug'
	 else
	   logger 'log/elasticsearch.log', :level => 'debug' 
	 end
	 Rails.logger.warn Rails.env
	 Rails.logger.warn YAML::load(File.open(Rails.root.join("./config/tire.yml")))[Rails.env]["url"]
   url(YAML::load(File.open(Rails.root.join("./config/tire.yml")))[Rails.env]["url"])
   client(HerokuRestClient)
 end