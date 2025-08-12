require "rails_helper"

RSpec.describe Word, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:word)).to be_valid
    end

    it "enforces uniqueness of word_order per verse" do
      verse = create(:verse)
      create(:word, verse: verse, word_order: 1)
      dup = build(:word, verse: verse, word_order: 1)
      expect(dup).not_to be_valid
      expect(dup.errors[:word_order]).to include("has already been taken")
    end

    it "requires word_order to be greater than 0" do
      word = build(:word, word_order: 0)
      expect(word).not_to be_valid
      expect(word.errors[:word_order]).to include("must be greater than 0")
    end
  end

  describe "scopes" do
    it "orders by word_order" do
      verse = create(:verse)
      w3 = create(:word, verse: verse, word_order: 3)
      w1 = create(:word, verse: verse, word_order: 1)
      w2 = create(:word, verse: verse, word_order: 2)
      
      expect(verse.words.by_order).to eq([w1, w2, w3])
    end

    it "filters by verse" do
      verse1 = create(:verse)
      verse2 = create(:verse)
      word1 = create(:word, verse: verse1)
      word2 = create(:word, verse: verse2)
      
      expect(Word.for_verse(verse1.id)).to include(word1)
      expect(Word.for_verse(verse1.id)).not_to include(word2)
    end

    it "filters words with strongs" do
      verse = create(:verse)
      word_with_strong = create(:word, verse: verse, strong_number: "G26")
      word_without_strong = create(:word, verse: verse, strong_number: nil)
      
      expect(Word.with_strongs).to include(word_with_strong)
      expect(Word.with_strongs).not_to include(word_without_strong)
    end

    it "filters by language" do
      verse = create(:verse)
      greek_word = create(:word, verse: verse, greek_word: "λόγος", hebrew_word: nil)
      hebrew_word = create(:word, verse: verse, hebrew_word: "אָמֵן", greek_word: nil)
      
      expect(Word.greek).to include(greek_word)
      expect(Word.hebrew).to include(hebrew_word)
    end
  end

  describe "associations" do
    it "belongs to a verse" do
      verse = create(:verse)
      word = create(:word, verse: verse)
      expect(word.verse).to eq(verse)
    end

    it "belongs to a strong" do
      strong = create(:strong)
      word = create(:word, strong: strong)
      expect(word.strong).to eq(strong)
    end

    it "has one chapter through verse" do
      chapter = create(:chapter)
      verse = create(:verse, chapter: chapter)
      word = create(:word, verse: verse)
      expect(word.chapter).to eq(chapter)
    end

    it "has one book through chapter" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      verse = create(:verse, chapter: chapter)
      word = create(:word, verse: verse)
      expect(word.book).to eq(book)
    end
  end

  describe "instance methods" do
    it "returns full reference" do
      book = create(:book, name: "John")
      chapter = create(:chapter, book: book, chapter_number: 3)
      verse = create(:verse, chapter: chapter, verse_number: 16)
      word = create(:word, verse: verse, word_order: 1)
      expect(word.full_reference).to eq("John 3:16:1")
    end

    it "displays greek word" do
      word = build(:word, greek_word: "λόγος")
      expect(word.display_greek).to eq("λόγος")
    end

    it "displays N/A for missing greek word" do
      word = build(:word, greek_word: nil)
      expect(word.display_greek).to eq("N/A")
    end

    it "displays hebrew word" do
      word = build(:word, hebrew_word: "אָמֵן")
      expect(word.display_hebrew).to eq("אָמֵן")
    end

    it "displays N/A for missing hebrew word" do
      word = build(:word, hebrew_word: nil)
      expect(word.display_hebrew).to eq("N/A")
    end

    it "displays spanish translation" do
      word = build(:word, spanish_translation: "palabra")
      expect(word.display_spanish).to eq("palabra")
    end

    it "displays N/A for missing spanish translation" do
      word = build(:word, spanish_translation: nil)
      expect(word.display_spanish).to eq("N/A")
    end

    it "displays strong number with G prefix for greek" do
      word = build(:word, strong_number: "G26", hebrew_word: nil, greek_word: "λόγος")
      expect(word.display_strong).to eq("G26")
    end

    it "displays strong number with H prefix for hebrew" do
      word = build(:word, strong_number: "H543", hebrew_word: "אָמֵן", greek_word: nil)
      expect(word.display_strong).to eq("H543")
    end

    it "displays N/A for missing strong number" do
      word = build(:word, strong_number: nil)
      expect(word.display_strong).to eq("N/A")
    end

    it "checks if has strong definition" do
      strong = create(:strong)
      word_with_strong = build(:word, strong: strong)
      word_without_strong = build(:word, strong: nil)
      
      expect(word_with_strong.has_strong_definition?).to be true
      expect(word_without_strong.has_strong_definition?).to be false
    end

    it "returns strong definition" do
      strong = create(:strong, definition: "word; saying")
      word = build(:word, strong: strong)
      expect(word.strong_definition).to eq("word; saying")
    end

    it "returns nil for missing strong definition" do
      word = build(:word, strong: nil)
      expect(word.strong_definition).to be_nil
    end

    it "builds searchable text" do
      word = build(:word, 
        greek_word: "λόγος",
        hebrew_word: nil,
        spanish_translation: "palabra",
        greek_grammar: "N-NSM",
        strong_number: "G3056"
      )
      expect(word.searchable_text).to include("λόγος", "palabra", "N-NSM", "G3056")
    end

    it "infers language from hebrew word" do
      word = build(:word, hebrew_word: "אָמֵן", greek_word: nil)
      expect(word.language).to eq("hebrew")
    end

    it "infers language from greek word" do
      word = build(:word, greek_word: "λόγος", hebrew_word: nil)
      expect(word.language).to eq("greek")
    end

    it "uses stored language when both present" do
      word = build(:word, greek_word: "λόγος", hebrew_word: "אָמֵן", language: "greek")
      expect(word.language).to eq("greek")
    end
  end

  describe "callbacks" do
    it "touches verse when word is updated" do
      verse = create(:verse)
      word = create(:word, verse: verse)
      original_updated_at = verse.updated_at
      
      travel(1.second) do
        word.update!(greek_word: "Updated word")
        expect(verse.reload.updated_at).to be > original_updated_at
      end
    end
  end
end
