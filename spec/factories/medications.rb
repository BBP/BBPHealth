FactoryGirl.define do
  factory :medication do
    sequence(:name) { |n| Faker::Name.name }
    sequence(:generic_name)  { |n| Faker::Name.name }
    sequence(:secondary_effects) { |n| Faker::Name.name }
    association :user
  end
end

