require 'tire'

Tire.configure do
  if Rails.env.production? || Rails.env.staging?
    logger STDERR, :level => 'debug'
  else
    logger 'log/elasticsearch.log', :level => 'debug' 
  end
  url(YAML::load(File.open(Rails.root.join("./config/tire.yml")))[Rails.env]["url"])
end