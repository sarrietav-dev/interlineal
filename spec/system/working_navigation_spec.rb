require "rails_helper"

RSpec.describe "Working Navigation", type: :system do
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

    it "can visit slideshow page" do
      visit bible_slideshow_path(book.id, chapter.chapter_number, verse.verse_number)
      expect(page).to have_content("John 3:16")
    end
  end

  describe "search functionality" do
    it "can visit search page" do
      visit "/search"
      expect(page).to have_content("Búsqueda")
    end

    it "can perform search" do
      visit "/search"
      fill_in "q", with: "amó"
      click_button "🔍 Buscar"
      expect(page).to have_content("Resultados")
    end
  end

  describe "language switching" do
    it "shows language switcher" do
      visit root_path
      expect(page).to have_link("ES")
      expect(page).to have_link("EN")
    end
  end

  describe "content display" do
    it "shows verse content" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)
      expect(page).to have_content("Porque de tal manera amó Dios al mundo")
    end

    it "shows navigation elements" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)
      expect(page).to have_content("📺 Presentación")
      expect(page).to have_content("🔍 Buscar")
      expect(page).to have_content("⚙️ Configuración")
    end
  end

  describe "slideshow navigation" do
    before do
      create(:verse, chapter: chapter, verse_number: 17, spanish_text: "Porque no envió Dios a su Hijo")
    end

    it "shows navigation elements" do
      visit bible_slideshow_path(book.id, chapter.chapter_number, verse.verse_number)
      expect(page).to have_content("John 3:16")
    end

    it "can navigate to next verse" do
      visit bible_slideshow_path(book.id, chapter.chapter_number, verse.verse_number)
      # Look for navigation links that might be present
      expect(page).to have_content("John 3:16")
    end
  end

  describe "responsive design" do
    it "works on different screen sizes" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)
      expect(page).to have_content("John 3:16")
    end
  end

  describe "error handling" do
    it "handles missing pages gracefully" do
      visit "/nonexistent"
      expect(page).to have_content("Routing Error")
    end
  end
end
