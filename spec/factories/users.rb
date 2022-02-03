FactoryBot.define do
  factory :user do
    association :stock
    username    { Faker::Internet.username }
    email       { Faker::Internet.email }
  end
end