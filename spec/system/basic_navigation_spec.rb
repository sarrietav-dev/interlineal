require "rails_helper"

RSpec.describe "Basic Navigation", type: :system do
  let(:book) { create(:book, name: "John", abbreviation: "Jn") }
  let(:chapter) { create(:chapter, book: book, chapter_number: 3) }
  let(:verse) { create(:verse, chapter: chapter, verse_number: 16, spanish_text: "Porque de tal manera amó Dios al mundo") }

  before do
    book
    chapter
    verse
  end

  describe "homepage" do
    it "redirects to first verse" do
      visit root_path
      expect(page).to have_content("John 3:16")
    end

    it "shows empty state when no books exist" do
      Book.destroy_all
      visit root_path
      expect(page).to have_content("No books available")
    end
  end

  describe "verse display" do
    it "shows verse content" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)
      expect(page).to have_content("John 3:16")
      expect(page).to have_content("Porque de tal manera amó Dios al mundo")
    end

    it "shows navigation buttons" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)
      expect(page).to have_button("Navigation")
      expect(page).to have_button("Settings")
    end
  end

  describe "chapter view" do
    it "shows chapter content" do
      visit bible_chapter_path(book.id, chapter.chapter_number)
      expect(page).to have_content("John 3")
      expect(page).to have_content("Porque de tal manera amó Dios al mundo")
    end
  end

  describe "search" do
    it "shows search form" do
      visit bible_search_path
      expect(page).to have_field("q")
      expect(page).to have_button("Search")
    end

    it "performs search" do
      visit bible_search_path
      fill_in "q", with: "amó"
      click_button "Search"
      expect(page).to have_content("John 3:16")
    end
  end

  describe "error pages" do
    it "handles non-existent book" do
      visit "/books/999"
      expect(page).to have_content("Book not found")
    end

    it "handles non-existent chapter" do
      visit "/books/#{book.id}/chapters/999"
      expect(page).to have_content("Chapter not found")
    end

    it "handles non-existent verse" do
      visit "/books/#{book.id}/chapters/#{chapter.chapter_number}/verses/999"
      expect(page).to have_content("Verse not found")
    end
  end

  describe "responsive design" do
    it "works on mobile" do
      page.driver.resize(375, 667)
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)
      expect(page).to have_content("John 3:16")
    end

    it "works on desktop" do
      page.driver.resize(1920, 1080)
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)
      expect(page).to have_content("John 3:16")
    end
  end
end
