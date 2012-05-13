# encoding: utf-8
User.destroy_all
user = User.new :email => 'sgruhier@gmail.com', :password => "azeaze", :password_confirmation => "azeaze"
user.admin = true
user.save!

Medication.destroy_all
Prescription.destroy_all
m = Medication.new name: "ibuprofene", generic_name: "ibuprofene", secondary_effects: "mal au dos, fatigue"
m.user = user
m.save!