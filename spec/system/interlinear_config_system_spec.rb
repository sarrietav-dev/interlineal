require 'rails_helper'

RSpec.describe "Interlinear Configuration", type: :system do
  let!(:book) { create(:book, name: "Genesis") }
  let!(:chapter) { create(:chapter, book: book, chapter_number: 1) }
  let!(:verse) { create(:verse, chapter: chapter, verse_number: 1, spanish_text: "En el principio creó Dios") }
  let!(:word1) { create(:word, verse: verse, word_order: 1, greek_word: "Ἐν", hebrew_word: "בראשית", spanish_translation: "En", strong_number: "1722") }
  let!(:word2) { create(:word, verse: verse, word_order: 2, greek_word: "ἀρχῇ", hebrew_word: "ברא", spanish_translation: "principio", strong_number: "746") }

  before do
    visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)
  end

  describe "default configuration display" do
    it "shows interlinear cards with default settings" do
      expect(page).to have_selector('.interlinear-word', count: 2)
      expect(page).to have_content('Ἐν')
      expect(page).to have_content('בראשית')
      expect(page).to have_content('En')
      expect(page).to have_content('principio')
    end

    it "displays Strong's numbers by default" do
      expect(page).to have_content('G1722')
      expect(page).to have_content('G746')
    end
  end

  describe "configuration modal" do
    before do
      click_on "⚙️"
      expect(page).to have_text("Display Elements")
    end

    it "opens the settings modal" do
      expect(page).to have_text("Display Elements")
      expect(page).to have_text("Layout Configuration")
      expect(page).to have_text("Font Sizes")
      expect(page).to have_text("Card Appearance")
    end

    it "shows current configuration state" do
      expect(page).to have_checked_field("show_greek")
      expect(page).to have_checked_field("show_hebrew")
      expect(page).to have_checked_field("show_spanish")
      expect(page).to have_checked_field("show_strongs")
    end

    describe "changing display elements" do
      it "can hide Greek text" do
        uncheck "show_greek"
        click_button "✓"

        expect(page).not_to have_content('Ἐν')
        expect(page).not_to have_content('ἀρχῇ')
        expect(page).to have_content('En')
        expect(page).to have_content('principio')
      end

      it "can hide Hebrew text" do
        uncheck "show_hebrew"
        click_button "✓"

        expect(page).to have_content('Ἐν')
        expect(page).not_to have_content('בראשית')
        expect(page).to have_content('En')
      end

      it "can hide Strong's numbers" do
        uncheck "show_strongs"
        click_button "✓"

        expect(page).not_to have_content('G1722')
        expect(page).not_to have_content('G746')
      end
    end

    describe "changing layout configuration" do
      it "can change primary language to Greek" do
        select "Greek", from: "primary_language"
        click_button "✓"

        # Greek should appear first in word cards now
        word_cards = page.all('.interlinear-word')
        first_card = word_cards.first
        # Check that Greek text appears before Spanish in the first card
        expect(first_card.text.index('Ἐν')).to be < first_card.text.index('En')
      end

      it "can change element arrangement" do
        select "Spanish → Primary → Secondary", from: "element_order"
        click_button "✓"

        # Spanish should appear first now
        word_cards = page.all('.interlinear-word')
        first_card = word_cards.first
        expect(first_card.text.index('En')).to be < first_card.text.index('Ἐν')
      end

      it "can change card theme to compact" do
        select "Compact", from: "card_theme"
        click_button "✓"

        expect(page).to have_selector('[data-theme="compact"]')
      end
    end

    describe "changing font sizes" do
      it "can adjust Greek font size" do
        greek_slider = find('input[name="greek_font_size"]')
        greek_slider.set(150)
        click_button "✓"

        # Check that the font size style is applied
        expect(page).to have_selector('span[style*="font-size: 150%"]')
      end

      it "can adjust Spanish font size" do
        spanish_slider = find('input[name="spanish_font_size"]')
        spanish_slider.set(120)
        click_button "✓"

        expect(page).to have_selector('span[style*="font-size: 120%"]')
      end
    end

    describe "changing card appearance" do
      it "can adjust card padding" do
        padding_slider = find('input[name="card_padding"]')
        padding_slider.set(120)
        click_button "✓"

        expect(page).to have_selector('[style*="--card-padding-multiplier: 1.2"]')
      end

      it "can adjust card spacing" do
        spacing_slider = find('input[name="card_spacing"]')
        spacing_slider.set(80)
        click_button "✓"

        expect(page).to have_selector('[style*="gap: 0.8rem"]')
      end
    end

    describe "reset functionality" do
      it "can reset to default settings" do
        # Change some settings
        uncheck "show_greek"
        select "Hebrew", from: "primary_language"
        find('input[name="greek_font_size"]').set(150)
        click_button "✓"

        # Verify changes took effect
        expect(page).not_to have_content('Ἐν')

        # Reset to defaults
        click_on "⚙️"
        click_link "🔄"

        # Verify reset worked
        expect(page).to have_checked_field("show_greek")
        expect(page).to have_select("primary_language", selected: "Spanish")
        expect(find('input[name="greek_font_size"]').value).to eq("100")

        click_button "✓"
        expect(page).to have_content('Ἐν') # Greek should be visible again
      end
    end
  end

  describe "slideshow mode" do
    before do
      click_link "📺"
      expect(page).to have_text("📖")
    end

    it "applies configuration in slideshow mode" do
      expect(page).to have_selector('.interlinear-word', count: 2)
      expect(page).to have_content('Ἐν')
      expect(page).to have_content('En')
    end

    it "can modify configuration from slideshow" do
      click_on "⚙️"
      uncheck "show_hebrew"
      click_button "✓"

      expect(page).not_to have_content('בראשית')
      expect(page).to have_content('Ἐν')
      expect(page).to have_content('En')
    end
  end

  describe "persistence across page loads" do
    it "maintains configuration after page reload" do
      # Configure settings
      click_on "⚙️"
      uncheck "show_hebrew"
      select "Greek", from: "primary_language"
      find('input[name="greek_font_size"]').set(130)
      click_button "✓"

      # Reload page
      visit bible_verse_path(book.id, chapter.chapter_number, verse.verse_number)

      # Verify settings persisted
      expect(page).not_to have_content('בראשית')
      expect(page).to have_content('Ἐν')

      # Check settings modal shows correct state
      click_on "⚙️"
      expect(page).not_to have_checked_field("show_hebrew")
      expect(page).to have_select("primary_language", selected: "Greek")
      expect(find('input[name="greek_font_size"]').value).to eq("130")
    end
  end

  describe "error handling" do
    it "handles invalid language combinations gracefully" do
      click_on "⚙️"
      select "Greek", from: "primary_language"
      select "Greek", from: "secondary_language"

      expect {
        click_button "✓"
      }.not_to change { page.current_path }

      # Should show some kind of error indication
      expect(page).to have_text("cannot be the same")
    end
  end
end
