namespace :app do
	task :create_indexes do
		cmd = <<-CURL
			curl -X DELETE "http://localhost:9200/prescriptions_development";
			curl -X POST "http://localhost:9200/prescriptions_development" -d '{"mappings":{"prescription":{"properties":{"medication_id":{"type":"string"},"secondary_effects_array":{"analyzer":"keyword","type":"string"},"created_at":{"type":"date"}}}},"settings":{}}';
			curl -X DELETE "http://localhost:9200/medications_development";
			curl -X POST "http://localhost:9200/medications_development" -d '{"mappings":{"medication":{"properties":{"secondary_effects_array":{"analyzer":"keyword","type":"string"}}}},"settings":{}}';
CURL
    puts cmd
  	system cmd
   end
  task :bootstrap => [
    'app:create_indexes', 
    'db:seed'
  ]
end
