# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# index = Medication.tire.index
# #index = Tire::Index.new(Rails.env + "medications")
# index.delete
# index.create
Medication.destroy_all
Medication.create! name: "ibuprofene", generic_name: "ibuprofene", secondary_effects: "mal au dos, mal à la tête"