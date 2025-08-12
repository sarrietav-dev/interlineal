require "rails_helper"

RSpec.describe "Bible System", type: :system do
  let(:book) { create(:book, name: "John", abbreviation: "Jn") }
  let(:chapter) { create(:chapter, book: book, chapter_number: 3) }
  let(:verse) { create(:verse, chapter: chapter, verse_number: 16, spanish_text: "Porque de tal manera amó Dios al mundo") }

  before do
    book
    chapter
    verse
  end

  describe "homepage navigation" do
    it "redirects to first verse on homepage" do
      visit root_path
      expect(page).to have_current_path(bible_verse_path(book.id, chapter.chapter_number, verse.verse_number))
      expect(page).to have_content("John 3:16")
    end

    it "shows empty state when no books exist" do
      Book.destroy_all
      visit root_path
      expect(page).to have_content("No books available")
    end
  end

  describe "verse display" do
    before do
      create(:word, verse: verse, greek_word: "λόγος", spanish_translation: "palabra", greek_grammar: "N-NSM")
    end

    it "displays verse with interlinear words" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      expect(page).to have_content("John 3:16")
      expect(page).to have_content("Porque de tal manera amó Dios al mundo")
      expect(page).to have_content("λόγος")
      expect(page).to have_content("palabra")
    end

    it "shows navigation buttons" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      expect(page).to have_button("Navigation")
      expect(page).to have_button("Settings")
    end
  end

  describe "navigation modal" do
    it "opens and closes navigation modal" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      click_button "Navigation"
      expect(page).to have_content("Navigate to")
      expect(page).to have_select("Book", selected: "John (Jn)")

      click_button "Close"
      expect(page).not_to have_content("Navigate to")
    end

    it "selects different book and navigates" do
      book2 = create(:book, name: "Matthew", abbreviation: "Mt")
      chapter2 = create(:chapter, book: book2, chapter_number: 1)
      verse2 = create(:verse, chapter: chapter2, verse_number: 1)

      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      click_button "Navigation"
      select "Matthew (Mt)", from: "Book"
      expect(page).to have_select("Chapter", selected: "1")
      expect(page).to have_select("Verse", selected: "1")

      click_button "Go"
      expect(page).to have_current_path(bible_slideshow_path(book2.id, 1, 1))
    end
  end

  describe "settings modal" do
    before do
      create(:word, verse: verse, greek_word: "λόγος", spanish_translation: "palabra")
    end

        it "opens and closes settings modal" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      click_link "⚙️ Configuración"
      expect(page).to have_content("Word Display Settings")
      expect(page).to have_field("Show Greek", checked: true)

      click_button "Close"
      expect(page).not_to have_content("Word Display Settings")
    end

    it "updates word display settings" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      click_link "⚙️ Configuración"
      uncheck "Show Greek"
      check "Show Word Order"
      click_button "Apply"

      # Should update the interlinear display
      expect(page).not_to have_content("λόγος")
      expect(page).to have_content("1") # word order
    end

    it "resets settings to defaults" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      click_link "⚙️ Configuración"
      uncheck "Show Greek"
      uncheck "Show Spanish"
      click_button "Reset"

      # Should restore default settings
      expect(page).to have_field("Show Greek", checked: true)
      expect(page).to have_field("Show Spanish", checked: true)
    end
  end

  describe "slideshow navigation" do
    before do
      create(:verse, chapter: chapter, verse_number: 17, spanish_text: "Porque no envió Dios a su Hijo")
    end

    it "navigates to next verse" do
      visit bible_slideshow_path(book.id, chapter.chapter_number, verse.verse_number)

      click_link "Versículo 17 ►"
      expect(page).to have_content("John 3:17")
      expect(page).to have_content("Porque no envió Dios a su Hijo")
    end

    it "navigates to previous verse" do
      visit bible_slideshow_path(book.id, chapter.chapter_number, 17)

      click_link "◄ Versículo 16"
      expect(page).to have_content("John 3:16")
      expect(page).to have_content("Porque de tal manera amó Dios al mundo")
    end

    it "navigates to next chapter when at last verse" do
      chapter2 = create(:chapter, book: book, chapter_number: 4)
      create(:verse, chapter: chapter2, verse_number: 1)

      visit bible_slideshow_path(book.id, chapter.chapter_number, 17)

      click_link "4:1 ►"
      expect(page).to have_content("John 4:1")
    end

    it "navigates to previous chapter when at first verse" do
      chapter0 = create(:chapter, book: book, chapter_number: 2)
      create(:verse, chapter: chapter0, verse_number: 1)

      visit bible_slideshow_path(book.id, chapter.chapter_number, 16)

      click_link "◄ 2:1"
      expect(page).to have_content("John 2:1")
    end

    it "disables navigation at boundaries" do
      visit bible_slideshow_path(book.id, chapter.chapter_number, 16)

      # Should not have previous link at first verse
      expect(page).not_to have_link("◄")

      visit bible_slideshow_path(book.id, chapter.chapter_number, 17)

      # Should not have next link at last verse
      expect(page).not_to have_link("►")
    end
  end

  describe "search functionality" do
    before do
      create(:word, verse: verse, greek_word: "λόγος", spanish_translation: "palabra")
    end

    it "searches for verses by spanish text" do
      visit bible_search_path

      fill_in "q", with: "amó"
      click_button "Search"

      expect(page).to have_content("John 3:16")
      expect(page).to have_content("Porque de tal manera amó Dios al mundo")
    end

    it "searches for greek words" do
      visit bible_search_path

      fill_in "q", with: "λόγος"
      click_button "Search"

      expect(page).to have_content("John 3:16")
    end

    it "searches for strong numbers" do
      word = create(:word, verse: verse, strong_number: "G26")
      visit bible_search_path

      fill_in "q", with: "G26"
      click_button "Search"

      expect(page).to have_content("John 3:16")
    end

    it "shows no results for short queries" do
      visit bible_search_path

      fill_in "q", with: "a"
      click_button "Search"

      expect(page).to have_content("No results found")
    end

    it "shows no results for empty queries" do
      visit bible_search_path

      fill_in "q", with: ""
      click_button "Search"

      expect(page).to have_content("No results found")
    end
  end

  describe "strong number links" do
    let(:strong) { create(:strong, strong_number: "G26", definition: "word; saying") }

    before do
      create(:word, verse: verse, strong: strong, strong_number: "G26")
    end

    it "opens strong definition modal" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      click_link "G26"
      expect(page).to have_content("Strong's G26")
      expect(page).to have_content("word; saying")
    end

    it "shows verses with this word" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      click_link "G26"
      expect(page).to have_content("Verses with this word:")
      expect(page).to have_content("John 3:16")
    end
  end

  describe "chapter view" do
    before do
      create(:verse, chapter: chapter, verse_number: 17, spanish_text: "Porque no envió Dios a su Hijo")
    end

    it "displays all verses in chapter" do
      visit bible_chapter_path(book.id, chapter.chapter_number)

      expect(page).to have_content("John 3")
      expect(page).to have_content("Porque de tal manera amó Dios al mundo")
      expect(page).to have_content("Porque no envió Dios a su Hijo")
    end

    it "allows navigation between verses" do
      visit bible_chapter_path(book.id, chapter.chapter_number)

      click_link "John 3:16"
      expect(page).to have_current_path(bible_verse_path(book.id, chapter.chapter_number, 16))

      click_link "John 3:17"
      expect(page).to have_current_path(bible_verse_path(book.id, chapter.chapter_number, 17))
    end
  end

  describe "responsive design" do
    it "works on mobile viewport" do
      page.driver.browser.manage.window.resize_to(375, 667) # iPhone SE
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      expect(page).to have_content("John 3:16")
      expect(page).to have_link("📖 Navegación")
      expect(page).to have_link("⚙️ Configuración")
    end

    it "works on tablet viewport" do
      page.driver.browser.manage.window.resize_to(768, 1024) # iPad
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      expect(page).to have_content("John 3:16")
    end

    it "works on desktop viewport" do
      page.driver.browser.manage.window.resize_to(1920, 1080) # Desktop
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      expect(page).to have_content("John 3:16")
    end
  end

  describe "error handling" do
    it "handles non-existent book gracefully" do
      visit "/books/999"
      expect(page).to have_content("Book not found")
    end

    it "handles non-existent chapter gracefully" do
      visit "/books/#{book.id}/chapters/999"
      expect(page).to have_content("Chapter not found")
    end

    it "handles non-existent verse gracefully" do
      visit "/books/#{book.id}/chapters/#{chapter.chapter_number}/verses/999"
      expect(page).to have_content("Verse not found")
    end
  end

  describe "language switching" do
    it "switches between languages" do
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      # Should show Spanish by default
      expect(page).to have_content("Biblia Interlineal")

      # Switch to English
      click_link "EN"
      expect(page).to have_content("Interlinear Bible")
    end
  end

  describe "keyboard navigation" do
    it "supports keyboard shortcuts" do
      visit bible_slideshow_path(book.id, chapter.chapter_number, verse.verse_number)

      # Test arrow key navigation
      page.send_keys(:arrow_right)
      expect(page).to have_content("John 3:17")

      page.send_keys(:arrow_left)
      expect(page).to have_content("John 3:16")
    end
  end
end
