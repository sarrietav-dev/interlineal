FactoryBot.define do
  factory :verse do
    association :chapter
    sequence(:verse_number) { |n| n }
    spanish_text { "Texto de ejemplo" }
  end
end
