FactoryBot.define do
  factory :comment do
    body{Faker::Lorem.paragraph}
    user
    article
  end
end
