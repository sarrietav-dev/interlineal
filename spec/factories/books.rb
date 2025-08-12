FactoryBot.define do
  factory :book do
    sequence(:name) { |n| "Book #{n}" }
    sequence(:abbreviation) { |n| "B#{n}" }
    testament { %w[OT NT].sample }
  end
end
