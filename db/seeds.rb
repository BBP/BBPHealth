# encoding: utf-8

User.destroy_all
user = User.new :email => 'sgruhier@gmail.com', :password => "azeaze", :password_confirmation => "azeaze", :nickname => "seb"

user.admin = true
user.save!

user = User.first

Medication.destroy_all
Prescription.destroy_all
m = Medication.new name: "ibuprofene", generic_name: "ibuprofene"

m.user = user
m.save!

effects = ["mal au dos", "fatigue", "vomissement"]
1.upto(10) do
  fx = [effects[rand(effects.length)], effects[rand(effects.length)]].uniq
  p = m.prescriptions.build lat: 46 + 2 + rand(100)/100.0, lng: 0 + 2 + rand(100)/100.0, secondary_effects_array: fx
  p.user = user
  p.save!
end


m = Medication.new name: "corgard", generic_name: "nadolol"

m.user = user
m.save!

effects = ["mal au dos", "mal au ventre", "nausée"]
1.upto(10) do
  fx = [effects[rand(effects.length)], effects[rand(effects.length)]].uniq
  p = m.prescriptions.build lat: 46 + 2 + rand(100)/100.0, lng: 0 + 2 + rand(100)/100.0, secondary_effects_array: fx
  p.user = user
  p.save!
end
