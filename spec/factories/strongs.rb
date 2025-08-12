FactoryBot.define do
  factory :strong do
    sequence(:strong_number) { |n| n.to_s }
    greek_word { "λόγος" }
    definition { "word; saying; message" }
    language { "greek" }
  end
end
