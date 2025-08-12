require "rails_helper"

RSpec.describe Strong, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:strong)).to be_valid
    end

    it "requires strong_number" do
      strong = Strong.new
      expect(strong).not_to be_valid
      expect(strong.errors[:strong_number]).to include("can't be blank")
    end

    it "enforces uniqueness of strong_number" do
      create(:strong, strong_number: "G26")
      dup = build(:strong, strong_number: "G26")
      expect(dup).not_to be_valid
      expect(dup.errors[:strong_number]).to include("has already been taken")
    end

    it "requires greek_word unless hebrew_word is present" do
      strong = build(:strong, greek_word: nil, hebrew_word: nil)
      expect(strong).not_to be_valid
      expect(strong.errors[:greek_word]).to include("can't be blank")
    end

    it "requires hebrew_word unless greek_word is present" do
      strong = build(:strong, hebrew_word: nil, greek_word: nil)
      expect(strong).not_to be_valid
      expect(strong.errors[:hebrew_word]).to include("can't be blank")
    end

    it "is valid with only greek_word" do
      strong = build(:strong, hebrew_word: nil, greek_word: "λόγος")
      expect(strong).to be_valid
    end

    it "is valid with only hebrew_word" do
      strong = build(:strong, greek_word: nil, hebrew_word: "אָמֵן")
      expect(strong).to be_valid
    end
  end

  describe "scopes" do
    it "orders by strong_number" do
      s3 = create(:strong, strong_number: "G3")
      s1 = create(:strong, strong_number: "G1")
      s2 = create(:strong, strong_number: "G2")

      expect(Strong.by_number).to eq([ s1, s2, s3 ])
    end

    it "filters with definitions" do
      strong_with_def = create(:strong, definition: "word; saying")
      strong_without_def = create(:strong, definition: nil)

      expect(Strong.with_definitions).to include(strong_with_def)
      expect(Strong.with_definitions).not_to include(strong_without_def)
    end

    it "filters by part of speech" do
      noun = create(:strong, part_of_speech: "noun")
      verb = create(:strong, part_of_speech: "verb")

      expect(Strong.by_part_of_speech("noun")).to include(noun)
      expect(Strong.by_part_of_speech("noun")).not_to include(verb)
    end

    it "filters by language" do
      greek_strong = create(:strong, greek_word: "λόγος", hebrew_word: nil, language: "greek")
      hebrew_strong = create(:strong, hebrew_word: "אָמֵן", greek_word: nil, language: "hebrew")

      expect(Strong.greek).to include(greek_strong)
      expect(Strong.hebrew).to include(hebrew_strong)
    end
  end

  describe "associations" do
    it "has many words" do
      strong = create(:strong)
      word1 = create(:word, strong: strong)
      word2 = create(:word, strong: strong)
      expect(strong.words).to include(word1, word2)
    end
  end

  describe "instance methods" do
    it "displays number with G prefix for greek" do
      strong = build(:strong, strong_number: "26", greek_word: "λόγος", hebrew_word: nil)
      expect(strong.display_number).to eq("G26")
    end

    it "displays number with H prefix for hebrew" do
      strong = build(:strong, strong_number: "543", hebrew_word: "אָמֵן", greek_word: nil)
      expect(strong.display_number).to eq("H543")
    end

    it "combines definitions" do
      strong = build(:strong, definition: "word", definition2: "saying")
      expect(strong.full_definition).to eq("word; saying")
    end

    it "handles single definition" do
      strong = build(:strong, definition: "word", definition2: nil)
      expect(strong.full_definition).to eq("word")
    end

    it "handles no definitions" do
      strong = build(:strong, definition: nil, definition2: nil)
      expect(strong.full_definition).to eq("")
    end

    it "counts words" do
      strong = create(:strong)
      create_list(:word, 3, strong: strong)
      expect(strong.word_count).to eq(3)
    end

    it "aggregates verses with this word across words" do
      strong = create(:strong)
      v1 = create(:verse)
      v2 = create(:verse)
      create(:word, verse: v1, strong_number: strong.strong_number)
      create(:word, verse: v2, strong_number: strong.strong_number)
      expect(strong.verses_with_this_word.sort_by(&:id)).to match_array([ v1, v2 ].sort_by(&:id))
    end

    it "builds searchable text" do
      strong = build(:strong,
        greek_word: "λόγος",
        hebrew_word: nil,
        pronunciation: "lo'-gos",
        definition: "word; saying",
        definition2: "message",
        part_of_speech: "noun",
        derivation: "from G3004",
        rv1909_definition: "palabra"
      )
      expect(strong.searchable_text).to include("λόγος", "lo'-gos", "word", "saying", "message", "noun", "from G3004", "palabra")
    end

    it "infers language from hebrew word" do
      strong = build(:strong, hebrew_word: "אָמֵן", greek_word: nil)
      expect(strong.language).to eq("hebrew")
    end

    it "infers language from greek word" do
      strong = build(:strong, greek_word: "λόγος", hebrew_word: nil)
      expect(strong.language).to eq("greek")
    end

    it "uses stored language when both present" do
      strong = build(:strong, greek_word: "λόγος", hebrew_word: "אָמֵן", language: "greek")
      expect(strong.language).to eq("greek")
    end
  end
end
