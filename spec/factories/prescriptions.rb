FactoryGirl.define do
  factory :prescription do
    association :medication
  end 
end
