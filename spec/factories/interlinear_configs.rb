FactoryBot.define do
  factory :interlinear_config do
    name { "Test Configuration" }
    session_id { SecureRandom.hex(16) }

    # Display settings
    show_greek { true }
    show_hebrew { true }
    show_spanish { true }
    show_strongs { true }
    show_grammar { true }
    show_pronunciation { false }
    show_word_order { false }

    # Layout settings
    primary_language { 'spanish' }
    secondary_language { 'greek' }
    element_order { 1 }

    # Font sizes (100 = default)
    greek_font_size { 100 }
    hebrew_font_size { 100 }
    spanish_font_size { 100 }
    strongs_font_size { 100 }
    grammar_font_size { 100 }
    pronunciation_font_size { 100 }

    # Card appearance
    card_padding { 100 }
    card_spacing { 100 }
    card_theme { 'default' }

    trait :compact_theme do
      card_theme { 'compact' }
      card_padding { 80 }
      card_spacing { 70 }
    end

    trait :spacious_theme do
      card_theme { 'spacious' }
      card_padding { 120 }
      card_spacing { 130 }
    end

    trait :large_fonts do
      greek_font_size { 150 }
      hebrew_font_size { 150 }
      spanish_font_size { 130 }
    end

    trait :minimal_display do
      show_greek { false }
      show_hebrew { false }
      show_strongs { false }
      show_grammar { false }
      show_pronunciation { false }
      show_word_order { false }
      # Only Spanish
      show_spanish { true }
    end

    trait :hebrew_primary do
      primary_language { 'hebrew' }
      secondary_language { 'spanish' }
      element_order { 4 } # Secondary → Primary → Spanish
    end

    trait :greek_primary do
      primary_language { 'greek' }
      secondary_language { 'hebrew' }
      element_order { 1 } # Primary → Secondary → Spanish
    end
  end
end
