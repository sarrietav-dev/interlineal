FactoryBot.define do
  factory :chapter do
    association :book
    sequence(:chapter_number) { |n| n }
  end
end
