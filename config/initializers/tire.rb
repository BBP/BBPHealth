Tire.configure do
   logger STDERR
   url(YAML::load(File.open(Rails.root.join("./config/tire.yml")))[Rails.env]["url"])
end
Tire::Model::Search.index_prefix "#{Rails.env}".downcase