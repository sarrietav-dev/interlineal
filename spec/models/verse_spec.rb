require "rails_helper"

RSpec.describe Verse, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:verse)).to be_valid
    end

    it "enforces uniqueness of verse_number per chapter" do
      chapter = create(:chapter)
      create(:verse, chapter: chapter, verse_number: 1)
      dup = build(:verse, chapter: chapter, verse_number: 1)
      expect(dup).not_to be_valid
      expect(dup.errors[:verse_number]).to include("has already been taken")
    end

    it "requires verse_number to be greater than 0" do
      verse = build(:verse, verse_number: 0)
      expect(verse).not_to be_valid
      expect(verse.errors[:verse_number]).to include("must be greater than 0")
    end
  end

  describe "scopes" do
    it "orders by verse number" do
      chapter = create(:chapter)
      v3 = create(:verse, chapter: chapter, verse_number: 3)
      v1 = create(:verse, chapter: chapter, verse_number: 1)
      v2 = create(:verse, chapter: chapter, verse_number: 2)
      
      expect(chapter.verses.by_number).to eq([v1, v2, v3])
    end

    it "filters by chapter" do
      chapter1 = create(:chapter)
      chapter2 = create(:chapter)
      verse1 = create(:verse, chapter: chapter1)
      verse2 = create(:verse, chapter: chapter2)
      
      expect(Verse.for_chapter(chapter1.id)).to include(verse1)
      expect(Verse.for_chapter(chapter1.id)).not_to include(verse2)
    end

    it "filters verses with Spanish text" do
      chapter = create(:chapter)
      verse_with_text = create(:verse, chapter: chapter, spanish_text: "Texto en español")
      verse_without_text = create(:verse, chapter: chapter, spanish_text: nil)
      
      expect(Verse.with_spanish_text).to include(verse_with_text)
      expect(Verse.with_spanish_text).not_to include(verse_without_text)
    end
  end

  describe "associations" do
    it "belongs to a chapter" do
      chapter = create(:chapter)
      verse = create(:verse, chapter: chapter)
      expect(verse.chapter).to eq(chapter)
    end

    it "has one book through chapter" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      verse = create(:verse, chapter: chapter)
      expect(verse.book).to eq(book)
    end

    it "has many words" do
      verse = create(:verse)
      word1 = create(:word, verse: verse)
      word2 = create(:word, verse: verse)
      expect(verse.words).to include(word1, word2)
    end
  end

  describe "instance methods" do
    it "returns full reference" do
      book = create(:book, name: "John")
      chapter = create(:chapter, book: book, chapter_number: 3)
      verse = create(:verse, chapter: chapter, verse_number: 16)
      expect(verse.full_reference).to eq("John 3:16")
    end

    it "counts words" do
      verse = create(:verse)
      create_list(:word, 4, verse: verse)
      expect(verse.word_count).to eq(4)
    end

    it "orders words by word_order" do
      verse = create(:verse)
      word3 = create(:word, verse: verse, word_order: 3)
      word1 = create(:word, verse: verse, word_order: 1)
      word2 = create(:word, verse: verse, word_order: 2)
      
      expect(verse.words_by_order).to eq([word1, word2, word3])
    end

    it "includes strongs with words" do
      verse = create(:verse)
      strong = create(:strong)
      word = create(:word, verse: verse, strong: strong)
      
      expect(verse.words_with_strongs).to include(word)
      expect(verse.words_with_strongs.first.strong).to eq(strong)
    end

    it "generates cache key with version" do
      verse = create(:verse)
      original_key = verse.cache_key_with_version
      
      travel(1.second) do
        verse.touch
        expect(verse.cache_key_with_version).not_to eq(original_key)
      end
    end
  end

  describe "navigation" do
    it "finds next verse" do
      chapter = create(:chapter)
      v1 = create(:verse, chapter: chapter, verse_number: 1)
      v2 = create(:verse, chapter: chapter, verse_number: 2)
      v3 = create(:verse, chapter: chapter, verse_number: 3)
      
      expect(v1.next_verse).to eq(v2)
      expect(v2.next_verse).to eq(v3)
      expect(v3.next_verse).to be_nil
    end

    it "finds previous verse" do
      chapter = create(:chapter)
      v1 = create(:verse, chapter: chapter, verse_number: 1)
      v2 = create(:verse, chapter: chapter, verse_number: 2)
      v3 = create(:verse, chapter: chapter, verse_number: 3)
      
      expect(v3.previous_verse).to eq(v2)
      expect(v2.previous_verse).to eq(v1)
      expect(v1.previous_verse).to be_nil
    end

    it "handles gaps in verse numbers" do
      chapter = create(:chapter)
      v1 = create(:verse, chapter: chapter, verse_number: 1)
      v5 = create(:verse, chapter: chapter, verse_number: 5)
      
      expect(v1.next_verse).to eq(v5)
      expect(v5.previous_verse).to eq(v1)
    end
  end

  describe "callbacks" do
    it "touches chapter when verse is updated" do
      chapter = create(:chapter)
      verse = create(:verse, chapter: chapter)
      original_updated_at = chapter.updated_at
      
      travel(1.second) do
        verse.update!(spanish_text: "Updated text")
        expect(chapter.reload.updated_at).to be > original_updated_at
      end
    end
  end
end
