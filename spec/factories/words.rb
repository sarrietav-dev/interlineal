FactoryBot.define do
  factory :word do
    association :verse
    association :strong, factory: :strong, strategy: :build
    sequence(:word_order) { |n| n }
    greek_word { "ἀγάπη" }
    greek_grammar { "N-NSF" }
    spanish_translation { "amor" }
    strong_number { strong&.strong_number }
  end
end
