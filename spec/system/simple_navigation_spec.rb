require "rails_helper"

RSpec.describe "Simple Navigation", type: :system do
  let(:book) { create(:book, name: "John", abbreviation: "Jn") }
  let(:chapter) { create(:chapter, book: book, chapter_number: 3) }
  let(:verse) { create(:verse, chapter: chapter, verse_number: 16, spanish_text: "Porque de tal manera amó Dios al mundo") }

  before do
    book
    chapter
    verse
  end

  describe "basic navigation" do
    it "can visit homepage" do
      visit root_path
      expect(page).to have_content("Biblia Interlineal")
    end

    it "can visit verse page" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)
      expect(page).to have_content("John 3:16")
    end

    it "can visit chapter page" do
      visit bible_chapter_path(book.id, chapter.chapter_number)
      expect(page).to have_content("John 3")
    end

    it "can visit slideshow page" do
      visit bible_slideshow_path(book.id, chapter.chapter_number, verse.verse_number)
      expect(page).to have_content("John 3:16")
    end
  end

  describe "search functionality" do
    it "can visit search page" do
      visit bible_search_path
      expect(page).to have_content("Búsqueda")
    end

    it "can perform search" do
      visit bible_search_path
      fill_in "q", with: "amó"
      click_button "Search"
      expect(page).to have_content("Resultados")
    end
  end

  describe "error handling" do
    it "handles 404 gracefully" do
      visit "/nonexistent"
      expect(page).to have_content("404")
    end
  end

  describe "language switching" do
    it "shows language switcher" do
      visit root_path
      expect(page).to have_link("ES")
      expect(page).to have_link("EN")
    end
  end
end
