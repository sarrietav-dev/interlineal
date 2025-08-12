require "rails_helper"

RSpec.describe Chapter, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:chapter)).to be_valid
    end

    it "enforces uniqueness of chapter_number per book" do
      book = create(:book)
      create(:chapter, book: book, chapter_number: 1)
      dup = build(:chapter, book: book, chapter_number: 1)
      expect(dup).not_to be_valid
      expect(dup.errors[:chapter_number]).to include("has already been taken")
    end

    it "requires chapter_number to be greater than 0" do
      chapter = build(:chapter, chapter_number: 0)
      expect(chapter).not_to be_valid
      expect(chapter.errors[:chapter_number]).to include("must be greater than 0")
    end
  end

  describe "scopes" do
    it "orders by chapter number" do
      book = create(:book)
      c3 = create(:chapter, book: book, chapter_number: 3)
      c1 = create(:chapter, book: book, chapter_number: 1)
      c2 = create(:chapter, book: book, chapter_number: 2)
      
      expect(book.chapters.by_number).to eq([c1, c2, c3])
    end

    it "filters by book" do
      book1 = create(:book)
      book2 = create(:book)
      chapter1 = create(:chapter, book: book1)
      chapter2 = create(:chapter, book: book2)
      
      expect(Chapter.for_book(book1.id)).to include(chapter1)
      expect(Chapter.for_book(book1.id)).not_to include(chapter2)
    end
  end

  describe "associations" do
    it "belongs to a book" do
      book = create(:book)
      chapter = create(:chapter, book: book)
      expect(chapter.book).to eq(book)
    end

    it "has many verses" do
      chapter = create(:chapter)
      verse1 = create(:verse, chapter: chapter)
      verse2 = create(:verse, chapter: chapter)
      expect(chapter.verses).to include(verse1, verse2)
    end

    it "has many words through verses" do
      chapter = create(:chapter)
      verse = create(:verse, chapter: chapter)
      word = create(:word, verse: verse)
      expect(chapter.words).to include(word)
    end
  end

  describe "instance methods" do
    it "returns full reference" do
      book = create(:book, name: "John")
      chapter = create(:chapter, book: book, chapter_number: 3)
      expect(chapter.full_reference).to eq("John 3")
    end

    it "counts verses" do
      chapter = create(:chapter)
      create_list(:verse, 5, chapter: chapter)
      expect(chapter.verse_count).to eq(5)
    end

    it "counts words" do
      chapter = create(:chapter)
      verse = create(:verse, chapter: chapter)
      create_list(:word, 3, verse: verse)
      expect(chapter.word_count).to eq(3)
    end
  end

  describe "navigation" do
    it "finds next chapter" do
      book = create(:book)
      c1 = create(:chapter, book: book, chapter_number: 1)
      c2 = create(:chapter, book: book, chapter_number: 2)
      c3 = create(:chapter, book: book, chapter_number: 3)
      
      expect(c1.next_chapter).to eq(c2)
      expect(c2.next_chapter).to eq(c3)
      expect(c3.next_chapter).to be_nil
    end

    it "finds previous chapter" do
      book = create(:book)
      c1 = create(:chapter, book: book, chapter_number: 1)
      c2 = create(:chapter, book: book, chapter_number: 2)
      c3 = create(:chapter, book: book, chapter_number: 3)
      
      expect(c3.previous_chapter).to eq(c2)
      expect(c2.previous_chapter).to eq(c1)
      expect(c1.previous_chapter).to be_nil
    end

    it "handles gaps in chapter numbers" do
      book = create(:book)
      c1 = create(:chapter, book: book, chapter_number: 1)
      c5 = create(:chapter, book: book, chapter_number: 5)
      
      expect(c1.next_chapter).to eq(c5)
      expect(c5.previous_chapter).to eq(c1)
    end
  end
end
