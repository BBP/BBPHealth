# encoding: utf-8
User.destroy_all
user = User.new :email => 'sgruhier@gmail.com', :password => "azeaze", :password_confirmation => "azeaze"
user.admin = true
user.save
Medication.destroy_all
Medication.create! name: "ibuprofene", generic_name: "ibuprofene", secondary_effects: "mal au dos, fatigue", :user => user