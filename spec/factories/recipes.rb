FactoryBot.define do
  factory :recipe do 
    association :author, factory: :user
    name { Faker::Food.dish }
    instructions { Faker::Food.description }
    portions { rand(1..12) }
  end 
end