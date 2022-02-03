FactoryBot.define do
  factory :stock do 
    invitation_token { SecureRandom.alphanumeric(6).upcase }
  end 
end