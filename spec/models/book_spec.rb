require "rails_helper"

RSpec.describe Book, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:book)).to be_valid
    end

    it "requires name, abbreviation and testament" do
      book = Book.new
      expect(book).not_to be_valid
      expect(book.errors.attribute_names).to include(:name, :abbreviation, :testament)
    end

    it "validates testament inclusion" do
      book = build(:book, testament: "INVALID")
      expect(book).not_to be_valid
      expect(book.errors[:testament]).to include("is not included in the list")
    end
  end

  describe "scopes" do
    it "orders by id with by_name scope" do
      b1 = create(:book, name: "Z", abbreviation: "Z1")
      b2 = create(:book, name: "A", abbreviation: "A1")
      expect(Book.by_name.first).to eq(b1)
      expect(Book.by_name.last).to eq(b2)
    end

    it "filters by testament" do
      nt_book = create(:book, testament: "NT")
      ot_book = create(:book, testament: "OT")
      expect(Book.new_testament).to include(nt_book)
      expect(Book.old_testament).to include(ot_book)
    end
  end

  describe "associations" do
    it "has many chapters" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      expect(book.chapters).to include(chapter)
    end

    it "has many verses through chapters" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      verse = create(:verse, chapter: chapter)
      expect(book.verses).to include(verse)
    end

    it "has many words through verses" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      verse = create(:verse, chapter: chapter)
      word = create(:word, verse: verse)
      expect(book.words).to include(word)
    end
  end

  describe "instance methods" do
    it "returns full name" do
      book = build(:book, name: "John", abbreviation: "Jn")
      expect(book.full_name).to eq("John (Jn)")
    end

    it "counts chapters" do
      book = create(:book)
      create_list(:chapter, 3, book: book)
      expect(book.chapter_count).to eq(3)
    end

    it "counts verses" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      create_list(:verse, 5, chapter: chapter)
      expect(book.verse_count).to eq(5)
    end

    it "counts words" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      verse = create(:verse, chapter: chapter)
      create_list(:word, 4, verse: verse)
      expect(book.word_count).to eq(4)
    end
  end

  describe "callbacks" do
    it "touches chapters when book is updated" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      original_updated_at = chapter.updated_at
      
      travel(1.second) do
        book.update!(name: "Updated Name")
        expect(chapter.reload.updated_at).to be > original_updated_at
      end
    end
  end
end
