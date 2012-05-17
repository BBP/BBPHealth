namespace :app do
	task :remove_indexes do
		cmd = <<-CURL
			curl -X DELETE "http://localhost:9200/prescriptions";
			curl -X POST "http://localhost:9200/prescriptions" -d '{"mappings":{"prescription":{"properties":{"medication_id":{"type":"string"},"secondary_effects_array":{"analyzer":"keyword","type":"string"},"created_at":{"type":"date"}}}},"settings":{}}';
			curl -X DELETE "http://localhost:9200/medications";
			curl -X POST "http://localhost:9200/medications" -d '{"mappings":{"medication":{"properties":{"secondary_effects_array":{"analyzer":"keyword","type":"string"}}}},"settings":{}}';
CURL
    puts cmd
  	system cmd
   end
  task :bootstrap => [
    'app:remove_indexes', 
    'db:seed'
  ]
end
