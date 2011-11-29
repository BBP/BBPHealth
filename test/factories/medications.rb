# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :medication do
      name "MyString"
      generic_name "MyString"
      secondary_effects ""
    end
end