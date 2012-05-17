FactoryGirl.define do
   trait :admin do
     admin true
   end

  factory :user do
    sequence(:email) { |n| Faker::Internet.email }
    password "secret"
    password_confirmation "secret"

    factory :admin, :traits => [:admin]
  end
end